import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/widgets/search_video.dart';

/// Displays the search tab UI for entering a YouTube URL or ID.
class LandingSearchTabView extends StatelessWidget {
  /// Creates a search tab view with the provided controller and callback.
  const LandingSearchTabView({
    super.key,
    required this.controller,
    required this.onSearch,
    this.autofocus = true,
  });

  /// Controls the text field value for the search input.
  final TextEditingController controller;

  /// Called when the user submits a search.
  final VoidCallback onSearch;

  /// Whether the input should autofocus when the tab is displayed.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SearchVideoField(
          videoFieldController: controller,
          onSearch: onSearch,
          actionIcon: Icons.search,
          autofocus: autofocus,
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
}
