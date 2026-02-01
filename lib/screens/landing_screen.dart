import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/search_history.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';
import 'package:youtube_comment_picker/widgets/comment_container.dart';
import 'package:youtube_comment_picker/widgets/search_video.dart';
import 'package:youtube_comment_picker/widgets/video_info.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.title});

  final String title;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  static const String _historyKey = 'search_history_items';

  final List<_TabEntry> _tabs = [];
  final List<SearchHistoryItem> _history = [];

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    for (final tab in _tabs) {
      tab.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_historyKey) ?? [];
    final items = <SearchHistoryItem>[];

    for (final raw in rawItems) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final item = SearchHistoryItem.fromJson(decoded);
        if (item.videoId.isNotEmpty) {
          items.add(item);
        }
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _history
        ..clear()
        ..addAll(items);
    });
  }

  Future<void> _saveHistoryItem(SearchHistoryItem item) async {
    _history.removeWhere((entry) => entry.videoId == item.videoId);
    _history.insert(0, item);
    if (_history.length > 10) {
      _history.removeRange(10, _history.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      _history.map((entry) => jsonEncode(entry.toJson())).toList(),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _removeHistoryItem(SearchHistoryItem item) async {
    _history.removeWhere((entry) => entry.videoId == item.videoId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      _history.map((entry) => jsonEncode(entry.toJson())).toList(),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);

    if (!mounted) {
      return;
    }

    setState(() {});
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        shape: const RoundedRectangleBorder(),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _addSearchTab() {
    final tab = _SearchTabState();
    setState(() {
      _tabs.add(_TabEntry.search(tab));
      _rebuildTabController(nextIndex: _tabs.length - 1);
    });
  }

  Future<void> _submitSearch(_SearchTabState searchTab, int tabIndex) async {
    final input = searchTab.controller.text.trim();
    if (input.isEmpty) {
      return;
    }

    final videoId = _extractVideoId(input);
    if (videoId == null) {
      _showError('The URL provided is not a valid YouTube video URL!');
      return;
    }

    await _openVideoById(
      videoId: videoId,
      query: input,
      replaceTabIndex: tabIndex,
    );
  }

  Future<void> _openVideoById({
    required String videoId,
    required String query,
    int? replaceTabIndex,
  }) async {
    final existingIndex = _tabs.indexWhere(
      (tab) => tab.isVideo && tab.video!.videoId == videoId,
    );
    if (existingIndex != -1) {
      int targetIndex = existingIndex;
      if (replaceTabIndex != null &&
          replaceTabIndex >= 0 &&
          replaceTabIndex < _tabs.length &&
          _tabs[replaceTabIndex].isSearch) {
        if (replaceTabIndex < existingIndex) {
          targetIndex = existingIndex - 1;
        }
        _tabs[replaceTabIndex].dispose();
        setState(() {
          _tabs.removeAt(replaceTabIndex);
          _rebuildTabController(nextIndex: targetIndex);
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController?.animateTo(targetIndex);
      });
      return;
    }

    final tab = _VideoTabState(
      videoId: videoId,
      query: query,
    );

    setState(() {
      if (replaceTabIndex != null &&
          replaceTabIndex >= 0 &&
          replaceTabIndex < _tabs.length &&
          _tabs[replaceTabIndex].isSearch) {
        _tabs[replaceTabIndex].dispose();
        _tabs[replaceTabIndex] = _TabEntry.video(tab);
        _rebuildTabController(nextIndex: replaceTabIndex);
      } else {
        _tabs.add(_TabEntry.video(tab));
        _rebuildTabController(nextIndex: _tabs.length - 1);
      }
    });

    await _loadTabData(tab);
  }

  Future<void> _loadTabData(_VideoTabState tab) async {
    tab.isLoading = true;
    setState(() {});

    try {
      tab.controller ??= YoutubePlayerController.fromVideoId(
        videoId: tab.videoId,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
        ),
      );

      final results = await Future.wait([
        getComments(tab.videoId, context),
        getVideoInformation(tab.videoId),
      ]);

      if (!mounted) {
        return;
      }

      final comments = results[0] as List<Comment?>? ?? [];
      final info = results[1] as VideoInformation?;

      tab.allComments = List<Comment?>.from(comments);
      tab.filteredComments = List<Comment?>.from(comments);
      tab.videoInfo = info;

      tab.allComments.sort(
        (a, b) => Comparable.compare(b?.likeCount ?? 0, a?.likeCount ?? 0),
      );
      tab.filteredComments.sort(
        (a, b) => Comparable.compare(b?.likeCount ?? 0, a?.likeCount ?? 0),
      );

      if (info != null) {
        await _saveHistoryItem(
          SearchHistoryItem(
            videoId: tab.videoId,
            title: info.title ?? tab.videoId,
            query: tab.query,
          ),
        );
      }
    } catch (e) {
      log.e(e);
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        tab.isLoading = false;
      });
    }
  }

  void _rebuildTabController({int? nextIndex}) {
    _tabController?.dispose();
    if (_tabs.isEmpty) {
      _tabController = null;
      return;
    }

    final targetIndex = (nextIndex ?? 0).clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: targetIndex,
    );
  }

  void _closeTab(int index) {
    if (index < 0 || index >= _tabs.length) {
      return;
    }

    final currentIndex = _tabController?.index ?? 0;
    final tab = _tabs.removeAt(index);
    tab.dispose();

    int nextIndex = currentIndex;
    if (_tabs.isNotEmpty) {
      if (index < currentIndex) {
        nextIndex = currentIndex - 1;
      } else if (index == currentIndex) {
        nextIndex = currentIndex.clamp(0, _tabs.length - 1);
      }
    }

    setState(() {
      _rebuildTabController(nextIndex: _tabs.isEmpty ? 0 : nextIndex);
    });
  }

  Widget _buildTabsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: kColorSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kColorBorder,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: kColorText,
                unselectedLabelColor: kColorTextMuted,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: kColorRedYtb.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kColorRedYtb.withValues(alpha: 0.4),
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  for (var i = 0; i < _tabs.length; i++)
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              _tabs[i].title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _closeTab(i),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            width: 44,
            child: ElevatedButton(
              onPressed: _addSearchTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: kColorSurface,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: kColorBorder,
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(
                Icons.add,
                color: kColorText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No recent searches yet',
                style: TextStyle(
                  color: kColorTextMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addSearchTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorSurface,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: kColorBorder,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: kColorText,
                ),
                label: const Text(
                  'New search',
                  style: TextStyle(
                    color: kColorText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Recent searches',
                  style: TextStyle(
                    color: kColorText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addSearchTab,
                  icon: const Icon(
                    Icons.add,
                    color: kColorText,
                  ),
                ),
                TextButton(
                  onPressed: _clearHistory,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: kColorTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    tileColor: kColorSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: kColorBorder,
                      ),
                    ),
                    title: Text(
                      item.displayTitle,
                      style: const TextStyle(
                        color: kColorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      item.videoId,
                      style: const TextStyle(
                        color: kColorTextMuted,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: kColorTextMuted,
                      ),
                      onPressed: () => _removeHistoryItem(item),
                    ),
                    onTap: () => _openVideoById(
                      videoId: item.videoId,
                      query: item.query.isEmpty ? item.videoId : item.query,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(_SearchTabState tab, int tabIndex) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SearchVideoField(
          videoFieldController: tab.controller,
          onSearch: () => _submitSearch(tab, tabIndex),
          actionIcon: Icons.search,
          autofocus: true,
        ),
        const SizedBox(height: 10),
        const Text(
          'Paste a YouTube URL or video ID to open a tab.',
          style: TextStyle(
            color: kColorTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTabView(_TabEntry tabEntry, int tabIndex) {
    if (tabEntry.isSearch) {
      return _buildSearchTab(tabEntry.search!, tabIndex);
    }

    final tab = tabEntry.video!;
    Widget content;
    if (tab.isLoading) {
      content = const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(
          color: kColorRedYtb,
        ),
      );
    } else if (tab.videoInfo == null) {
      content = const Center(
        key: ValueKey('error'),
        child: Text(
          'Unable to load video',
          style: TextStyle(
            color: kColorText,
            fontSize: 16,
          ),
        ),
      );
    } else {
      final hasComments = tab.allComments.isNotEmpty;
      content = Column(
        key: ValueKey('content-${tab.videoId}'),
        children: <Widget>[
          VideoInfo(
            videoInfo: tab.videoInfo,
            ytbController: tab.controller,
          ),
          const SizedBox(height: 24),
          if (hasComments)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: tab.filterController,
                style: const TextStyle(
                  color: kColorText,
                ),
                decoration:
                    kInputDecoration(labeText: 'Search comments').copyWith(
                  labelStyle: const TextStyle(
                    color: kColorText,
                    fontSize: 20,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: kColorTextMuted,
                  ),
                ),
                onChanged: (term) {
                  setState(() {
                    if (term.trim().isNotEmpty) {
                      tab.filteredComments = tab.allComments
                          .where(
                            (comment) =>
                                comment!.text!.toLowerCase().containsAny(
                                      term.toLowerCase().split(' '),
                                    ),
                          )
                          .toList();
                    } else {
                      tab.filteredComments = List<Comment?>.from(
                        tab.allComments,
                      );
                    }
                  });
                },
              ),
            )
          else
            const Text(
              'No comments found',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kColorTextMuted,
              ),
            ),
          if (hasComments && tab.filteredComments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: kColorSurface,
                    elevation: 0,
                    primary: false,
                    pinned: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                    shadowColor: Colors.transparent,
                    title: Text(
                      '${tab.filteredComments.length} comments found',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kColorText,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CommentWidget(
                            comment: tab.filteredComments[index]!,
                            highlightText: tab.filterController.text,
                          ),
                        );
                      },
                      childCount: tab.filteredComments.length,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (hasComments) ...[
            const SizedBox(height: 20),
            const Text(
              'No comments match your search',
              style: TextStyle(
                color: kColorTextMuted,
              ),
            ),
          ],
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: kColorText,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: kColorBackground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kColorBackground,
              kColorSurface,
              kColorBackground,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            if (_tabs.isEmpty)
              _buildHistory()
            else ...[
              _buildTabsHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs
                      .asMap()
                      .entries
                      .map((entry) => _buildTabView(entry.value, entry.key))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoTabState {
  _VideoTabState({
    required this.videoId,
    required this.query,
  });

  final String videoId;
  final String query;
  VideoInformation? videoInfo;
  YoutubePlayerController? controller;
  final TextEditingController filterController = TextEditingController();
  List<Comment?> allComments = [];
  List<Comment?> filteredComments = [];
  bool isLoading = true;

  String get title => videoInfo?.title ?? videoId;

  void dispose() {
    filterController.dispose();
    controller?.close();
  }
}

class _SearchTabState {
  final TextEditingController controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}

class _TabEntry {
  _TabEntry.search(this.search) : video = null;
  _TabEntry.video(this.video) : search = null;

  final _SearchTabState? search;
  final _VideoTabState? video;

  bool get isSearch => search != null;
  bool get isVideo => video != null;

  String get title => isSearch ? 'New Search' : (video?.title ?? 'Video');

  void dispose() {
    search?.dispose();
    video?.dispose();
  }
}
