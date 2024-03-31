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

  Future<void> prepareComments(String video) async {
    allComments = [];
    filteredComments = [];
    String videoId = '';

    if (video.length > 11) {
      videoId = video.after('?v=').before('&ab_channel');
    } else {
      videoId = video;
    }
    final res = await Future.wait([
      getComments(video, context),
      getVideoInformation(video),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
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
              icon: const Icon(Icons.refresh),
            ),
        ],
        backgroundColor: kColorRedYtb,
      ),
      body: Column(
        children: <Widget>[
          if (allComments.isEmpty)
            SearchVideo(
              videoFieldController: _videoFieldController,
              onSearch: () async {
                if (_videoFieldController.text.isNotEmpty) {
                  isSearching = true;
                  setState(() {});
                  await prepareComments(_videoFieldController.text);
                  isSearching = false;
                  setState(() {});
                }
              },
            )
          else
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: YoutubePlayer(
                controller: _controller!,
              ),
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
            VideoInfo(videoInfo: videoInfo),
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
                      onChanged: (value) {
                        log.f(value.length);

                        setState(() {
                          if (value.isNotEmpty) {
                            filteredComments = allComments
                                .where(
                                  (c) => c!.text!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
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
                        backgroundColor: kColorRedYtb,
                        elevation: 12,
                        primary: false,
                        pinned: true,
                        shadowColor: kColorRedYtb,
                        title: Text(
                          '${filteredComments.length} comments found',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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
