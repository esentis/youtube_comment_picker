import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_event.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_state.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/search_history.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';

const String _historyKey = 'search_history_items';

/// Coordinates landing screen state, tabs, and history.
class LandingBloc extends Bloc<LandingEvent, LandingState> {
  /// Creates a landing bloc with an optional preferences override.
  LandingBloc({SharedPreferences? preferences})
      : _preferences =
            preferences != null ? Future.value(preferences) : _prefs(),
        super(LandingState.initial()) {
    on<LandingStarted>(_onStarted);
    on<LandingAddSearchTabRequested>(_onAddSearchTabRequested);
    on<LandingSearchSubmitted>(_onSearchSubmitted);
    on<LandingHistoryOpened>(_onHistoryOpened);
    on<LandingCloseTabRequested>(_onCloseTabRequested);
    on<LandingFilterChanged>(_onFilterChanged);
    on<LandingClearHistoryRequested>(_onClearHistoryRequested);
    on<LandingRemoveHistoryItemRequested>(_onRemoveHistoryItemRequested);
    on<LandingTabIndexChanged>(_onTabIndexChanged);
    on<LandingMessageConsumed>(_onMessageConsumed);
  }

  final Future<SharedPreferences> _preferences;
  int _nextTabId = 0;

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  Future<void> _onStarted(
    LandingStarted event,
    Emitter<LandingState> emit,
  ) async {
    final history = await _loadHistory();
    emit(state.copyWith(history: history));
  }

  void _onAddSearchTabRequested(
    LandingAddSearchTabRequested event,
    Emitter<LandingState> emit,
  ) {
    final tabs = List<LandingTab>.from(state.tabs)
      ..add(LandingSearchTab(id: _nextTabId++));
    emit(
      state.copyWith(
        tabs: tabs,
        activeTabIndex: tabs.length - 1,
      ),
    );
  }

  Future<void> _onSearchSubmitted(
    LandingSearchSubmitted event,
    Emitter<LandingState> emit,
  ) async {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final videoId = _extractVideoId(trimmed);
    if (videoId == null) {
      emit(
        state.withMessage(
          'The URL provided is not a valid YouTube video URL!',
        ),
      );
      return;
    }

    await _openVideo(
      emit,
      videoId: videoId,
      query: trimmed,
      replaceTabId: event.tabId,
    );
  }

  Future<void> _onHistoryOpened(
    LandingHistoryOpened event,
    Emitter<LandingState> emit,
  ) async {
    final query =
        event.item.query.isEmpty ? event.item.videoId : event.item.query;
    await _openVideo(
      emit,
      videoId: event.item.videoId,
      query: query,
    );
  }

  void _onCloseTabRequested(
    LandingCloseTabRequested event,
    Emitter<LandingState> emit,
  ) {
    final tabs = List<LandingTab>.from(state.tabs);
    final index = tabs.indexWhere((tab) => tab.id == event.tabId);
    if (index == -1) {
      return;
    }

    tabs.removeAt(index);

    var nextIndex = state.activeTabIndex;
    if (tabs.isEmpty) {
      nextIndex = 0;
    } else if (index < nextIndex) {
      nextIndex = nextIndex - 1;
    } else if (index == nextIndex) {
      nextIndex = nextIndex.clamp(0, tabs.length - 1);
    }

    emit(
      state.copyWith(
        tabs: tabs,
        activeTabIndex: nextIndex,
      ),
    );
  }

  void _onFilterChanged(
    LandingFilterChanged event,
    Emitter<LandingState> emit,
  ) {
    final tabs = List<LandingTab>.from(state.tabs);
    final index = tabs.indexWhere(
      (tab) => tab is LandingVideoTab && tab.id == event.tabId,
    );
    if (index == -1) {
      return;
    }

    final videoTab = tabs[index] as LandingVideoTab;
    final filtered = _filterComments(videoTab.allComments, event.term);
    tabs[index] = videoTab.copyWith(
      filterTerm: event.term,
      filteredComments: filtered,
    );

    emit(state.copyWith(tabs: tabs));
  }

  Future<void> _onClearHistoryRequested(
    LandingClearHistoryRequested event,
    Emitter<LandingState> emit,
  ) async {
    await _persistHistory(const []);
    emit(state.copyWith(history: const []));
  }

  Future<void> _onRemoveHistoryItemRequested(
    LandingRemoveHistoryItemRequested event,
    Emitter<LandingState> emit,
  ) async {
    final history = state.history
        .where((entry) => entry.videoId != event.item.videoId)
        .toList();
    await _persistHistory(history);
    emit(state.copyWith(history: history));
  }

  void _onTabIndexChanged(
    LandingTabIndexChanged event,
    Emitter<LandingState> emit,
  ) {
    if (event.index == state.activeTabIndex) {
      return;
    }
    emit(state.copyWith(activeTabIndex: event.index));
  }

  void _onMessageConsumed(
    LandingMessageConsumed event,
    Emitter<LandingState> emit,
  ) {
    if (state.message == null) {
      return;
    }
    emit(state.clearMessage());
  }

  Future<void> _openVideo(
    Emitter<LandingState> emit, {
    required String videoId,
    required String query,
    int? replaceTabId,
  }) async {
    final existingIndex = state.tabs.indexWhere(
      (tab) => tab is LandingVideoTab && tab.videoId == videoId,
    );

    if (existingIndex != -1) {
      final tabs = List<LandingTab>.from(state.tabs);
      var activeIndex = existingIndex;
      if (replaceTabId != null) {
        final replaceIndex = tabs.indexWhere((tab) => tab.id == replaceTabId);
        if (replaceIndex != -1 && tabs[replaceIndex] is LandingSearchTab) {
          tabs.removeAt(replaceIndex);
          if (replaceIndex < existingIndex) {
            activeIndex = existingIndex - 1;
          }
        }
      }

      emit(
        state.copyWith(
          tabs: tabs,
          activeTabIndex: activeIndex,
        ),
      );
      return;
    }

    final newTab = LandingVideoTab(
      id: _nextTabId++,
      videoId: videoId,
      query: query,
      isLoading: true,
      allComments: const [],
      filteredComments: const [],
    );

    final tabs = List<LandingTab>.from(state.tabs);
    var insertIndex = tabs.length;
    if (replaceTabId != null) {
      final replaceIndex = tabs.indexWhere((tab) => tab.id == replaceTabId);
      if (replaceIndex != -1 && tabs[replaceIndex] is LandingSearchTab) {
        tabs[replaceIndex] = newTab;
        insertIndex = replaceIndex;
      } else {
        tabs.add(newTab);
        insertIndex = tabs.length - 1;
      }
    } else {
      tabs.add(newTab);
      insertIndex = tabs.length - 1;
    }

    emit(
      state.copyWith(
        tabs: tabs,
        activeTabIndex: insertIndex,
      ),
    );

    await _loadVideoTabData(
      emit,
      tabId: newTab.id,
      videoId: videoId,
      query: query,
    );
  }

  Future<void> _loadVideoTabData(
    Emitter<LandingState> emit, {
    required int tabId,
    required String videoId,
    required String query,
  }) async {
    List<Comment?> comments = const [];
    String? errorMessage;

    try {
      comments = await getComments(videoId);
    } on YoutubeServiceException catch (e, stackTrace) {
      errorMessage = e.message;
      developer.log(
        'Failed to load comments.',
        name: 'landing_bloc',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      errorMessage = 'Unable to load comments.';
      developer.log(
        'Unexpected error while loading comments.',
        name: 'landing_bloc',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final info = await getVideoInformation(videoId);

    final sorted = List<Comment?>.from(comments)
      ..sort(
        (a, b) => Comparable.compare(
          b?.likeCount ?? 0,
          a?.likeCount ?? 0,
        ),
      );

    final filterTerm = _currentFilterTerm(tabId);
    final updatedTabs = _updateVideoTab(
      tabId,
      info: info,
      allComments: sorted,
      filteredComments: _filterComments(sorted, filterTerm),
      isLoading: false,
    );

    if (updatedTabs == null) {
      return;
    }

    var nextState = state.copyWith(tabs: updatedTabs);

    if (info != null) {
      final historyItem = SearchHistoryItem(
        videoId: videoId,
        title: info.title ?? videoId,
        query: query,
      );
      final history = _updatedHistory(state.history, historyItem);
      await _persistHistory(history);
      nextState = nextState.copyWith(history: history);
    }

    if (errorMessage != null) {
      nextState = nextState.withMessage(errorMessage);
    }

    emit(nextState);
  }

  List<LandingTab>? _updateVideoTab(
    int tabId, {
    required VideoInformation? info,
    required List<Comment?> allComments,
    required List<Comment?> filteredComments,
    required bool isLoading,
  }) {
    final tabs = List<LandingTab>.from(state.tabs);
    final index = tabs.indexWhere(
      (tab) => tab is LandingVideoTab && tab.id == tabId,
    );
    if (index == -1) {
      return null;
    }

    final videoTab = tabs[index] as LandingVideoTab;
    tabs[index] = videoTab.copyWith(
      videoInfo: info,
      allComments: allComments,
      filteredComments: filteredComments,
      isLoading: isLoading,
    );
    return tabs;
  }

  String _currentFilterTerm(int tabId) {
    for (final tab in state.tabs) {
      if (tab is LandingVideoTab && tab.id == tabId) {
        return tab.filterTerm;
      }
    }
    return '';
  }

  String? _extractVideoId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.length <= 11 && !trimmed.contains(' ')) {
      return trimmed;
    }

    if (trimmed.contains('/shorts/')) {
      var id = trimmed.after('/shorts/');
      if (id.contains('?')) {
        id = id.before('?');
      }
      if (id.contains('&')) {
        id = id.before('&');
      }
      return id.isEmpty ? null : id;
    }

    if (trimmed.contains('youtu.be/')) {
      var id = trimmed.after('youtu.be/');
      if (id.contains('?')) {
        id = id.before('?');
      }
      if (id.contains('&')) {
        id = id.before('&');
      }
      return id.isEmpty ? null : id;
    }

    if (trimmed.contains('?v=')) {
      var id = trimmed.after('?v=');
      if (id.contains('&')) {
        id = id.before('&');
      }
      return id.isEmpty ? null : id;
    }

    return null;
  }

  List<Comment?> _filterComments(List<Comment?> comments, String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) {
      return List<Comment?>.from(comments);
    }

    final tokens = trimmed.toLowerCase().split(' ');
    return comments.where((comment) {
      final text = comment?.text?.toLowerCase();
      if (text == null) {
        return false;
      }
      return text.containsAny(tokens);
    }).toList();
  }

  Future<List<SearchHistoryItem>> _loadHistory() async {
    final prefs = await _preferences;
    final rawItems = prefs.getStringList(_historyKey) ?? [];
    final items = <SearchHistoryItem>[];

    for (final raw in rawItems) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final item = SearchHistoryItem.fromJson(decoded);
        if (item.videoId.isNotEmpty) {
          items.add(item);
        }
      } catch (e, stackTrace) {
        developer.log(
          'Failed to decode history item.',
          name: 'landing_bloc',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    return items;
  }

  List<SearchHistoryItem> _updatedHistory(
    List<SearchHistoryItem> history,
    SearchHistoryItem item,
  ) {
    final updated = List<SearchHistoryItem>.from(history)
      ..removeWhere((entry) => entry.videoId == item.videoId)
      ..insert(0, item);

    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }

    return updated;
  }

  Future<void> _persistHistory(List<SearchHistoryItem> history) async {
    final prefs = await _preferences;
    await prefs.setStringList(
      _historyKey,
      history.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }
}
