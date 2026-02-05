import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/constants.dart';

/// Displays the tab header row for open searches and videos.
class LandingTabsHeader extends StatelessWidget {
  /// Creates a tabs header with close buttons and an add action.
  const LandingTabsHeader({
    super.key,
    required this.tabController,
    required this.titles,
    required this.onAddSearchTab,
    required this.onCloseTab,
    required this.onTabSelected,
  });

  /// Controls the active tab index and tab animations.
  final TabController tabController;

  /// Titles to render for each tab.
  final List<String> titles;

  /// Called when the user taps the add tab button.
  final VoidCallback onAddSearchTab;

  /// Called when the user taps the close icon for a tab.
  final ValueChanged<int> onCloseTab;

  /// Called when the user selects a tab.
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
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
                border: const Border(
                  top: BorderSide(color: kColorBorder),
                  left: BorderSide(color: kColorBorder),
                  right: BorderSide(color: kColorBorder),
                ),
              ),
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                onTap: onTabSelected,
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
                  for (var i = 0; i < titles.length; i++)
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              titles[i],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => onCloseTab(i),
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
}
