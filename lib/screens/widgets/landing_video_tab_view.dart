import 'package:flutter/material.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/widgets/comment_container.dart';
import 'package:youtube_comment_picker/widgets/video_info.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Shows the video tab content, including video info and comment list.
class LandingVideoTabView extends StatelessWidget {
  /// Creates a video tab view with the provided video state.
  const LandingVideoTabView({
    super.key,
    required this.videoId,
    required this.videoInfo,
    required this.controller,
    required this.filterController,
    required this.allComments,
    required this.filteredComments,
    required this.isLoading,
    required this.onFilterChanged,
  });

  /// The current video's ID for display and keying.
  final String videoId;

  /// Metadata about the current video, if loaded.
  final VideoInformation? videoInfo;

  /// The YouTube player controller for inline playback.
  final YoutubePlayerController? controller;

  /// Controls the search field used to filter comments.
  final TextEditingController filterController;

  /// All comments loaded for the video.
  final List<Comment?> allComments;

  /// Comments matching the current filter term.
  final List<Comment?> filteredComments;

  /// Whether the tab is loading data.
  final bool isLoading;

  /// Called when the user changes the filter text.
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const _LoadingState(
        key: ValueKey('loading'),
      );
    } else if (videoInfo == null) {
      content = const _ErrorState(
        key: ValueKey('error'),
      );
    } else {
      content = _VideoContent(
        key: ValueKey('content-$videoId'),
        videoInfo: videoInfo,
        controller: controller,
        filterController: filterController,
        allComments: allComments,
        filteredComments: filteredComments,
        onFilterChanged: onFilterChanged,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: content,
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: kColorRedYtb,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Unable to load video',
        style: TextStyle(
          color: kColorText,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  const _VideoContent({
    super.key,
    required this.videoInfo,
    required this.controller,
    required this.filterController,
    required this.allComments,
    required this.filteredComments,
    required this.onFilterChanged,
  });

  final VideoInformation? videoInfo;
  final YoutubePlayerController? controller;
  final TextEditingController filterController;
  final List<Comment?> allComments;
  final List<Comment?> filteredComments;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final hasComments = allComments.isNotEmpty;

    return Column(
      children: <Widget>[
        VideoInfo(
          videoInfo: videoInfo,
          ytbController: controller,
        ),
        const SizedBox(height: 24),
        if (hasComments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: _CommentsSearchField(
              controller: filterController,
              onFilterChanged: onFilterChanged,
            ),
          )
        else
          const _NoCommentsFoundText(),
        if (hasComments && filteredComments.isNotEmpty) ...[
          const SizedBox(height: 10),
          Expanded(
            child: _CommentsList(
              comments: filteredComments,
              highlightText: filterController.text,
            ),
          ),
        ] else if (hasComments) ...[
          const SizedBox(height: 20),
          const _NoMatchingCommentsText(),
        ],
      ],
    );
  }
}

class _CommentsSearchField extends StatelessWidget {
  const _CommentsSearchField({
    required this.controller,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: kColorText,
      ),
      decoration: kInputDecoration(labeText: 'Search comments').copyWith(
        labelStyle: const TextStyle(
          color: kColorText,
          fontSize: 20,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: kColorTextMuted,
        ),
      ),
      onChanged: onFilterChanged,
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({
    required this.comments,
    required this.highlightText,
  });

  final List<Comment?> comments;
  final String highlightText;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            '${comments.length} comments found',
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
                  comment: comments[index]!,
                  highlightText: highlightText,
                ),
              );
            },
            childCount: comments.length,
          ),
        ),
      ],
    );
  }
}

class _NoCommentsFoundText extends StatelessWidget {
  const _NoCommentsFoundText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'No comments found',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: kColorTextMuted,
      ),
    );
  }
}

class _NoMatchingCommentsText extends StatelessWidget {
  const _NoMatchingCommentsText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'No comments match your search',
      style: TextStyle(
        color: kColorTextMuted,
      ),
    );
  }
}
