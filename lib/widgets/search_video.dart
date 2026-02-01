import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/constants.dart';

class SearchVideoField extends StatelessWidget {
  const SearchVideoField({
    super.key,
    required this.videoFieldController,
    required this.onSearch,
    this.actionIcon = Icons.add,
    this.autofocus = false,
  });

  final TextEditingController videoFieldController;
  final VoidCallback onSearch;
  final IconData actionIcon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 30,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: videoFieldController,
              autofocus: autofocus,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              style: const TextStyle(
                color: kColorText,
              ),
              decoration:
                  kInputDecoration(labeText: 'Video URL or ID').copyWith(
                hintText: 'Paste a YouTube URL or video ID',
                prefixIcon: const Icon(
                  Icons.search,
                  color: kColorTextMuted,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            height: 52,
            width: 52,
            child: ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: kColorRedYtb,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Icon(
                actionIcon,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
