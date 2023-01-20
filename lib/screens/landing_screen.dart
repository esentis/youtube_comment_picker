// ignore_for_file: cast_nullable_to_non_nullable

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:lottie/lottie.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comments_response.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';
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
  // bool showFilteredComments = false;

  final List<double> values = [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 10.0, 15.0];
  int selectedCommentsCount = 1;

  ScrollController _commentsScrollController = ScrollController();
  YoutubePlayerController? _controller;

  Future<void> prepareComments(String video) async {
    allComments = [];
    filteredComments = [];
    String videoId = '';

    if (video.length > 11) {
      videoId = video.after('?v=').before('&ab_channel')!;
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

      allComments
          .sort((a, b) => Comparable.compare(b!.likeCount!, a!.likeCount!));
      filteredComments
          .sort((a, b) => Comparable.compare(b!.likeCount!, a!.likeCount!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kColorRedYtb,
      ),
      body: Column(
        children: <Widget>[
          if (allComments.isEmpty) ...[
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _videoFieldController,
                decoration: kInputDecoration(labeText: 'URL or Video ID'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Bounceable(
              scaleFactor: 0.7,
              onTap: () async {
                if (_videoFieldController.text.isNotEmpty) {
                  isSearching = true;
                  setState(() {});
                  await prepareComments(_videoFieldController.text);
                  isSearching = false;
                  setState(() {});
                }
              },
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
          ] else
            YoutubePlayer(
              controller: _controller!,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      videoInfo!.title!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text('${videoInfo?.viewCount} views'),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  TextField(
                    controller: _filterTextController,
                    decoration: kInputDecoration(labeText: 'Search comments'),
                    onChanged: (value) {
                      log.wtf(value.length);

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
                          log.wtf('Value is empty');
                          filteredComments = allComments;
                        }
                      });

                      // else {
                      //   if (filteredComments.isNotEmpty) {
                      //     log.wtf('Resetting filters');
                      //     filteredComments = [];
                      //     filteredComments.addAll(allComments);
                      //     log.wtf('Filters are ${filteredComments.length}');
                      //     setState(() {});
                      //   }
                      // }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${filteredComments.length} comments found',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    key: ValueKey(
                                      filteredComments[index]!
                                          .authorProfileImageUrl!,
                                    ),
                                    leading: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          kLaunchUrl(
                                            filteredComments[index]!
                                                    .authorChannel ??
                                                '',
                                          );
                                        },
                                        child: ExtendedImage.network(
                                          filteredComments[index]!
                                              .authorProfileImageUrl!,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.fill,
                                          shape: BoxShape.circle,
                                          loadStateChanged: (state) {
                                            if (state.extendedImageLoadState ==
                                                LoadState.failed) {
                                              return Image.network(
                                                'https://i.imgur.com/qV26MhU.png',
                                              );
                                            }
                                            if (state.extendedImageLoadState ==
                                                LoadState.loading) {
                                              return LottieBuilder.asset(
                                                'assets/loading.json',
                                                height: 100,
                                              );
                                            }
                                          },
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    subtitle: Column(
                                      children: [
                                        SubstringHighlight(
                                          text: filteredComments[index]!.text!,
                                          term: _filterTextController.text,
                                          textStyleHighlight: TextStyle(
                                            color: kColorRedYtb,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.thumb_up),
                                            const SizedBox(width: 10),
                                            Text(
                                              filteredComments[index]!
                                                  .likeCount!
                                                  .toString(),
                                              style: TextStyle(
                                                color: kColorRedYtb,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      filteredComments[index]!.authorName!,
                                      style: TextStyle(
                                        color: kColorRedYtb,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: filteredComments.length,
                        ),
                      )
                    ],
                  ],
                ),
              )
            ]
          ]
        ],
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
