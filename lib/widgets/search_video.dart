import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:youtube_comment_picker/constants.dart';

class SearchVideoField extends StatelessWidget {
  const SearchVideoField({
    super.key,
    required TextEditingController videoFieldController,
    required this.onSearch,
  }) : _videoFieldController = videoFieldController;

  final TextEditingController _videoFieldController;
  final VoidCallback onSearch;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 30.0,
            top: 40,
          ),
          child: TextField(
            controller: _videoFieldController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration:
                kInputDecoration(labeText: 'Enter a video URL or ID').copyWith(
              label: const Center(
                child: Text("Enter a video URL or ID"),
              ),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Bounceable(
          scaleFactor: 0.7,
          onTap: onSearch,
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              color: kColorRedYtb,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
