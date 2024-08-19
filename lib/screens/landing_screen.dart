// ignore_for_file: cast_nullable_to_non_nullable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comment.dart';
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

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _videoFieldController = TextEditingController();
  final TextEditingController _filterTextController = TextEditingController();

  VideoInformation? videoInfo;

  List<Comment?> allComments = [];
  List<Comment?> filteredComments = [];
  List<Comment?> randomFilteredComments = [];

  bool isSearching = false;

  final List<double> values = [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 10.0, 15.0];
  int selectedCommentsCount = 1;

  late YoutubePlayerController? _controller;

  Future<void> prepareComments(String videoUrl) async {
    allComments = [];
    filteredComments = [];
    String videoId = '';

    if (videoUrl.length > 11) {
      videoId = videoUrl.after('?v=');
      if (videoId.contains('&')) {
        videoId = videoId.before('&');
      }
    } else {
      videoId = videoUrl;
    }
    try {
      final res = await Future.wait([
        getComments(videoUrl, context),
        getVideoInformation(videoUrl),
      ]);
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
        ),
      );

      if (res[0] != null && res[1] != null) {
        allComments.addAll(res[0] as List<Comment?>);
        filteredComments.addAll(res[0] as List<Comment?>);
        videoInfo = res[1] as VideoInformation?;

        allComments.sort(
          (a, b) => Comparable.compare(b?.likeCount ?? 0, a?.likeCount ?? 0),
        );
        filteredComments.sort(
          (a, b) => Comparable.compare(b?.likeCount ?? 0, a?.likeCount ?? 0),
        );
      }
      isSearching = false;
    } catch (e) {
      log.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          if (allComments.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  allComments = [];
                  filteredComments = [];
                  randomFilteredComments = [];
                  videoInfo = null;
                  _videoFieldController.clear();
                  _filterTextController.clear();
                });
              },
              icon: const Icon(
                Icons.refresh,
                size: 35,
                color: Colors.white,
              ),
            ),
        ],
        backgroundColor: kColorRedYtb,
      ),
      body: Column(
        children: <Widget>[
          if (allComments.isEmpty)
            SearchVideoField(
              videoFieldController: _videoFieldController,
              onSearch: () async {
                if (_videoFieldController.text.isNotEmpty) {
                  isSearching = true;
                  setState(() {});
                  await prepareComments(_videoFieldController.text);

                  setState(() {});
                }
              },
            ),
          const SizedBox(
            height: 20,
          ),
          if (isSearching)
            LottieBuilder.asset(
              'assets/loading.json',
              height: 100,
            )
          else if (videoInfo != null) ...[
            VideoInfo(
              videoInfo: videoInfo,
              ytbController: _controller,
            ),
            const SizedBox(
              height: 30,
            ),
            if (allComments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _filterTextController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: kInputDecoration(labeText: 'Search comments')
                          .copyWith(
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      onChanged: (term) {
                        log.f(term.length);

                        setState(() {
                          if (term.isNotEmpty) {
                            filteredComments = allComments
                                .where(
                                  (comment) =>
                                      comment!.text!.toLowerCase().containsAny(
                                            term.toLowerCase().split(' '),
                                          ),
                                )
                                .toList();
                          } else {
                            log.f('Value is empty');
                            filteredComments = allComments;
                          }
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              const Text(
                'No comments found',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (filteredComments.isNotEmpty) ...[
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (filteredComments.isNotEmpty) ...[
                      SliverAppBar(
                        backgroundColor: kColorGreyYtb,
                        elevation: 12,
                        primary: false,
                        pinned: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        shadowColor: kColorGreyYtb.withOpacity(0.5),
                        title: Text(
                          '${filteredComments.length} comments found',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommentWidget(
                                comment: filteredComments[index]!,
                                highlightText: _filterTextController.text,
                              ),
                            );
                          },
                          childCount: filteredComments.length,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
