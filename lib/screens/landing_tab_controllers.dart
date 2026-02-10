import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_state.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Manages text and video player controllers for landing screen tabs.
///
/// Keeps controllers in sync with [LandingState.tabs], creating and disposing
/// them as tabs are added or removed.
class LandingTabControllers {
  final Map<int, TextEditingController> _searchControllers = {};
  final Map<int, TextEditingController> _filterControllers = {};
  final Map<int, YoutubePlayerController> _playerControllers = {};
  final Set<int> _knownTabIds = {};

  /// Returns the search controller for [tabId], or null if not found.
  TextEditingController? searchControllerFor(int tabId) =>
      _searchControllers[tabId];

  /// Returns the filter controller for [tabId], or null if not found.
  TextEditingController? filterControllerFor(int tabId) =>
      _filterControllers[tabId];

  /// Returns the video player controller for [tabId], or null if not found.
  YoutubePlayerController? playerControllerFor(int tabId) =>
      _playerControllers[tabId];

  /// Syncs controllers with [state.tabs].
  ///
  /// Creates controllers for new tabs and disposes them for removed tabs.
  void sync(LandingState state) {
    final activeIds = <int>{};

    for (final tab in state.tabs) {
      activeIds.add(tab.id);
      if (tab is LandingSearchTab) {
        _disposeVideoControllers(tab.id);
        _searchControllers.putIfAbsent(tab.id, TextEditingController.new);
      } else if (tab is LandingVideoTab) {
        _disposeSearchControllers(tab.id);
        final filterController = _filterControllers.putIfAbsent(
          tab.id,
          () => TextEditingController(text: tab.filterTerm),
        );
        if (filterController.text != tab.filterTerm) {
          filterController.text = tab.filterTerm;
        }
        _playerControllers.putIfAbsent(
          tab.id,
          () => YoutubePlayerController.fromVideoId(
            videoId: tab.videoId,
            params: const YoutubePlayerParams(
              showFullscreenButton: true,
            ),
          ),
        );
      }
    }

    for (final id in _knownTabIds.difference(activeIds)) {
      _disposeSearchControllers(id);
      _disposeVideoControllers(id);
    }

    _knownTabIds
      ..clear()
      ..addAll(activeIds);
  }

  void _disposeSearchControllers(int tabId) {
    _searchControllers.remove(tabId)?.dispose();
  }

  void _disposeVideoControllers(int tabId) {
    _filterControllers.remove(tabId)?.dispose();
    _playerControllers.remove(tabId)?.close();
  }

  /// Disposes all managed controllers.
  void dispose() {
    for (final controller in _searchControllers.values) {
      controller.dispose();
    }
    _searchControllers.clear();
    for (final controller in _filterControllers.values) {
      controller.dispose();
    }
    _filterControllers.clear();
    for (final controller in _playerControllers.values) {
      controller.close();
    }
    _playerControllers.clear();
    _knownTabIds.clear();
  }
}
