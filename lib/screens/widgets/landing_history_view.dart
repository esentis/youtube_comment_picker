import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/search_history.dart';

/// Shows the landing page history state, including empty and populated views.
class LandingHistoryView extends StatelessWidget {
  /// Creates a history view with callbacks for user actions.
  const LandingHistoryView({
    super.key,
    required this.history,
    required this.onAddSearchTab,
    required this.onClearHistory,
    required this.onRemoveHistoryItem,
    required this.onOpenHistoryItem,
  });

  /// Items to display in the recent history list.
  final List<SearchHistoryItem> history;

  /// Called when the user starts a new search.
  final VoidCallback onAddSearchTab;

  /// Called when the user clears the entire history list.
  final VoidCallback onClearHistory;

  /// Called when the user removes a single history entry.
  final ValueChanged<SearchHistoryItem> onRemoveHistoryItem;

  /// Called when the user opens a history entry.
  final ValueChanged<SearchHistoryItem> onOpenHistoryItem;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Expanded(
        child: _EmptyHistoryView(
          onAddSearchTab: onAddSearchTab,
        ),
      );
    }

    return Expanded(
      child: _HistoryListView(
        history: history,
        onAddSearchTab: onAddSearchTab,
        onClearHistory: onClearHistory,
        onRemoveHistoryItem: onRemoveHistoryItem,
        onOpenHistoryItem: onOpenHistoryItem,
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({
    required this.onAddSearchTab,
  });

  final VoidCallback onAddSearchTab;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            onPressed: onAddSearchTab,
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
    );
  }
}

class _HistoryListView extends StatelessWidget {
  const _HistoryListView({
    required this.history,
    required this.onAddSearchTab,
    required this.onClearHistory,
    required this.onRemoveHistoryItem,
    required this.onOpenHistoryItem,
  });

  final List<SearchHistoryItem> history;
  final VoidCallback onAddSearchTab;
  final VoidCallback onClearHistory;
  final ValueChanged<SearchHistoryItem> onRemoveHistoryItem;
  final ValueChanged<SearchHistoryItem> onOpenHistoryItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onPressed: onAddSearchTab,
                icon: const Icon(
                  Icons.add,
                  color: kColorText,
                ),
              ),
              TextButton(
                onPressed: onClearHistory,
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
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
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
                    onPressed: () => onRemoveHistoryItem(item),
                  ),
                  onTap: () => onOpenHistoryItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
