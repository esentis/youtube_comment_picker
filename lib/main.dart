import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comments_response.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YouTube Comment Picker',
      home: const MyHomePage(title: 'YouTube Comment Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _videoFieldController = TextEditingController();
  final TextEditingController _filterTextController = TextEditingController();

  VideoInformation? videoInfo;

  List<Comment?> allComments = [];
  List<Comment?> filteredComments = [];
  List<Comment?> randomFilteredComments = [];

  bool isSearching = false;
  bool showFilteredComments = false;

  final List<double> values = [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 10.0, 15.0];
  int selectedCommentsCount = 1;

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
      backgroundColor: kColorRedYtb.withOpacity(0.1),
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
                    setState(() {
                      showFilteredComments = false;
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
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_filterTextController.text.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                Bounceable(
                  onTap: () async {
                    setState(() {
                      showFilteredComments = !showFilteredComments;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                      color: filteredComments.isEmpty
                          ? kColorRedYtb.withOpacity(0.3)
                          : kColorRedYtb,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        showFilteredComments
                            ? 'Hide ${filteredComments.length} filtered comments'
                            : filteredComments.isEmpty
                                ? 'No comments found'
                                : 'Show ${filteredComments.length} filtered comments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // if (showFilteredComments)
                //   Bounceable(
                //     onTap: () async {
                //       final Random random = Random();
                //       randomFilteredComments = [];
                //       while (randomFilteredComments.length !=
                //           selectedCommentsCount) {
                //         final int randomNumber =
                //             random.nextInt(filteredComments.length) + 1;
                //         randomFilteredComments
                //             .add(filteredComments[randomNumber]);
                //       }
                //       setState(() {});
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 250,
                //       decoration: BoxDecoration(
                //         color: kColorRedYtb,
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       child: Center(
                //         child: Text(
                //           'Show new $selectedCommentsCount random comments',
                //           style: TextStyle(
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                const SizedBox(
                  height: 30,
                ),
                if (showFilteredComments)
                  SizedBox(
                    height: 350,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: filteredComments.length,
                      itemBuilder: (context, index) => ListTile(
                        key: ValueKey(
                          filteredComments[index]!.authorProfileImageUrl!,
                        ),
                        leading: ExtendedImage.network(
                          filteredComments[index]!.authorProfileImageUrl!,
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
                        title: SubstringHighlight(
                          text: filteredComments[index]!.text!,
                          term: _filterTextController.text,
                          textStyleHighlight: TextStyle(
                            color: kColorRedYtb,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(filteredComments[index]!.authorName!),
                      ),
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
