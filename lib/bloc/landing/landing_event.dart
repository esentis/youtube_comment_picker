import 'package:flutter/foundation.dart';
import 'package:youtube_comment_picker/models/search_history.dart';

/// Base class for landing screen events.
@immutable
abstract class LandingEvent {
  /// Creates a landing event.
  const LandingEvent();
}

/// Triggers loading of persisted history.
class LandingStarted extends LandingEvent {
  /// Creates a start event.
  const LandingStarted();
}

/// Requests a new empty search tab.
class LandingAddSearchTabRequested extends LandingEvent {
  /// Creates an add-search-tab event.
  const LandingAddSearchTabRequested();
}

/// Submits a search query for a specific tab.
class LandingSearchSubmitted extends LandingEvent {
  /// Creates a search submission for [tabId] and [query].
  const LandingSearchSubmitted({required this.tabId, required this.query});

  /// The tab that submitted the query.
  final int tabId;

  /// The raw query or URL submitted by the user.
  final String query;
}

/// Opens a video from the user's search history.
class LandingHistoryOpened extends LandingEvent {
  /// Creates a history-open event for [item].
  const LandingHistoryOpened({required this.item});

  /// The history entry that was selected.
  final SearchHistoryItem item;
}

/// Requests closing the tab identified by [tabId].
class LandingCloseTabRequested extends LandingEvent {
  /// Creates a close-tab event.
  const LandingCloseTabRequested({required this.tabId});

  /// The identifier of the tab to close.
  final int tabId;
}

/// Updates the filter term for a video tab.
class LandingFilterChanged extends LandingEvent {
  /// Creates a filter-change event for [tabId].
  const LandingFilterChanged({required this.tabId, required this.term});

  /// The tab receiving the filter update.
  final int tabId;

  /// The new filter term.
  final String term;
}

/// Clears the stored search history.
class LandingClearHistoryRequested extends LandingEvent {
  /// Creates a clear-history event.
  const LandingClearHistoryRequested();
}

/// Removes a specific history entry.
class LandingRemoveHistoryItemRequested extends LandingEvent {
  /// Creates a remove-history event for [item].
  const LandingRemoveHistoryItemRequested({required this.item});

  /// The history entry to remove.
  final SearchHistoryItem item;
}

/// Updates the active tab index.
class LandingTabIndexChanged extends LandingEvent {
  /// Creates a tab-index change event.
  const LandingTabIndexChanged({required this.index});

  /// The newly selected tab index.
  final int index;
}

/// Marks the current message as handled.
class LandingMessageConsumed extends LandingEvent {
  /// Creates a message-consumed event.
  const LandingMessageConsumed();
}
