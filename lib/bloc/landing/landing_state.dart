import 'package:flutter/foundation.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/search_history.dart';
import 'package:youtube_comment_picker/models/video_information.dart';

/// Immutable state for the landing screen.
@immutable
class LandingState {
  /// Creates landing state with the provided fields.
  const LandingState({
    required this.history,
    required this.tabs,
    required this.activeTabIndex,
    required this.message,
    required this.messageId,
  });

  /// Recently opened videos for quick access.
  final List<SearchHistoryItem> history;

  /// Open tabs for searches and loaded videos.
  final List<LandingTab> tabs;

  /// Index of the currently active tab.
  final int activeTabIndex;

  /// A transient user-facing message, such as an error.
  final String? message;

  /// Monotonic identifier for message changes.
  final int messageId;

  /// Returns the initial landing state.
  factory LandingState.initial() {
    return const LandingState(
      history: [],
      tabs: [],
      activeTabIndex: 0,
      message: null,
      messageId: 0,
    );
  }

  /// Returns a copy with updated fields.
  LandingState copyWith({
    List<SearchHistoryItem>? history,
    List<LandingTab>? tabs,
    int? activeTabIndex,
    int? messageId,
  }) {
    return LandingState(
      history: history ?? this.history,
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      message: message,
      messageId: messageId ?? this.messageId,
    );
  }

  /// Returns a copy with a new user-facing message.
  LandingState withMessage(String message) {
    return LandingState(
      history: history,
      tabs: tabs,
      activeTabIndex: activeTabIndex,
      message: message,
      messageId: messageId + 1,
    );
  }

  /// Returns a copy with the message cleared.
  LandingState clearMessage() {
    return LandingState(
      history: history,
      tabs: tabs,
      activeTabIndex: activeTabIndex,
      message: null,
      messageId: messageId,
    );
  }
}

/// Base class for tabs displayed on the landing screen.
@immutable
abstract class LandingTab {
  /// Creates a landing tab with a unique [id].
  const LandingTab({required this.id});

  /// Unique identifier for this tab.
  final int id;

  /// Title to display in the tab header.
  String get title;
}

/// Represents a tab that collects a video search query.
class LandingSearchTab extends LandingTab {
  /// Creates a search tab with a unique [id].
  const LandingSearchTab({required super.id});

  @override
  String get title => 'New Search';
}

/// Represents a tab showing a loaded video and its comments.
class LandingVideoTab extends LandingTab {
  /// Creates a video tab with its associated data.
  const LandingVideoTab({
    required super.id,
    required this.videoId,
    required this.query,
    required this.isLoading,
    required this.allComments,
    required this.filteredComments,
    this.filterTerm = '',
    this.videoInfo,
  });

  /// The YouTube video ID for this tab.
  final String videoId;

  /// The original query string used to open the tab.
  final String query;

  /// Whether the tab is still loading data.
  final bool isLoading;

  /// All loaded comments for the video.
  final List<Comment?> allComments;

  /// Comments matching the current filter term.
  final List<Comment?> filteredComments;

  /// The current filter term for comment searching.
  final String filterTerm;

  /// Metadata about the loaded video, if available.
  final VideoInformation? videoInfo;

  @override
  String get title => videoInfo?.title ?? videoId;

  /// Returns a copy with updated video data.
  LandingVideoTab copyWith({
    VideoInformation? videoInfo,
    bool? isLoading,
    List<Comment?>? allComments,
    List<Comment?>? filteredComments,
    String? filterTerm,
  }) {
    return LandingVideoTab(
      id: id,
      videoId: videoId,
      query: query,
      isLoading: isLoading ?? this.isLoading,
      allComments: allComments ?? this.allComments,
      filteredComments: filteredComments ?? this.filteredComments,
      filterTerm: filterTerm ?? this.filterTerm,
      videoInfo: videoInfo ?? this.videoInfo,
    );
  }
}
