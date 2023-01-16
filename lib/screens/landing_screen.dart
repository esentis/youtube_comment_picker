// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:lottie/lottie.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comments_response.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';

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

  Future<void> prepareComments(String video) async {
    allComments = [];
    filteredComments = [];
    final res = await Future.wait([
      getComments(video, context),
      getVideoInformation(video),
    ]);

    if (res[0] != null && res[1] != null) {
      allComments.addAll(res[0] as List<Comment?>);
      filteredComments.addAll(res[0] as List<Comment?>);
      videoInfo = res[1] as VideoInformation?;
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
            const SizedBox(
              height: 20,
            ),
            if (isSearching)
              LottieBuilder.asset(
                'assets/loading.json',
                height: 100,
              )
            else if (videoInfo != null) ...[
              Text(
                videoInfo!.title!,
                textAlign: TextAlign.center,
              ),
              Text('${videoInfo?.viewCount} views'),
              Text(
                '${allComments.length} total comments found',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _filterTextController,
                  decoration: kInputDecoration(labeText: 'Search comments'),
                  onChanged: (value) {
                    if (value.length > 2) {
                      setState(() {
                        //  showFilteredComments = false;
                        randomFilteredComments = [];
                        filteredComments = allComments
                            .where(
                              (c) => c!.text!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()),
                            )
                            .toList();
                        final Random random = Random();
                        if (filteredComments.isNotEmpty) {
                          while (randomFilteredComments.length !=
                              selectedCommentsCount) {
                            final int randomNumber =
                                random.nextInt(filteredComments.length) + 1;
                            randomFilteredComments
                                .add(filteredComments[randomNumber]);
                          }
                        }
                      });
                    }
                  },
                ),
              ),
              if (_filterTextController.text.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 300,
                  child: CustomScrollView(
                    slivers: [
                      if (_filterTextController.text.isNotEmpty) ...[
                        const SliverPadding(
                          padding: EdgeInsets.only(top: 30),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, index) {
                              return ListTile(
                                key: ValueKey(
                                  filteredComments[index]!
                                      .authorProfileImageUrl!,
                                ),
                                leading: ExtendedImage.network(
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SubstringHighlight(
                                      text: filteredComments[index]!.text!,
                                      term: _filterTextController.text,
                                      textStyleHighlight: TextStyle(
                                        color: kColorRedYtb,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => log.wtf(
                                          filteredComments[index]!
                                              .authorChannel),
                                      child: Text('Page'),
                                    )
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
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
