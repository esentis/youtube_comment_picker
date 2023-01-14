import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kColorRedYtb,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            const Text('Please provide video ID or URL'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _videoFieldController,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((state) {
                  return kColorRedYtb;
                }),
              ),
              onPressed: () async {
                if (_videoFieldController.text.isNotEmpty) {
                  isSearching = true;
                  setState(() {});
                  await prepareComments(_videoFieldController.text);
                  isSearching = false;
                  setState(() {});
                }
              },
              child: const Text('Search'),
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
                  decoration: InputDecoration(
                    focusColor: Colors.red,
                    label: const Text('Filter'),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

                      while (randomFilteredComments.length !=
                          selectedCommentsCount) {
                        final int randomNumber =
                            random.nextInt(filteredComments.length) + 1;
                        randomFilteredComments
                            .add(filteredComments[randomNumber]);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_filterTextController.text.isNotEmpty) ...[
                Text(
                  '${filteredComments.length} comments found containg above filter',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: selectedCommentsCount.toDouble(),
                  max: values.length - 1,
                  min: 1,
                  divisions: values.length - 1,
                  onChangeEnd: (v) {
                    setState(() {
                      selectedCommentsCount = v.toInt();

                      final Random random = Random();
                      randomFilteredComments = [];
                      while (randomFilteredComments.length !=
                          selectedCommentsCount) {
                        final int randomNumber =
                            random.nextInt(filteredComments.length) + 1;
                        randomFilteredComments
                            .add(filteredComments[randomNumber]);
                      }
                    });
                  },
                  onChanged: (v) {
                    setState(() {
                      selectedCommentsCount = v.toInt();
                      if (showFilteredComments) {
                        showFilteredComments = false;
                      }
                    });
                  },
                  label: '$selectedCommentsCount',
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((state) {
                      return kColorRedYtb;
                    }),
                  ),
                  onPressed: () async {
                    setState(() {
                      showFilteredComments = !showFilteredComments;
                    });
                  },
                  child: Text(
                    showFilteredComments
                        ? 'Hide filtered comments'
                        : 'Show $selectedCommentsCount filtered comments',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (showFilteredComments)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((state) {
                        return kColorRedYtb;
                      }),
                    ),
                    onPressed: () async {
                      final Random random = Random();
                      randomFilteredComments = [];
                      while (randomFilteredComments.length !=
                          selectedCommentsCount) {
                        final int randomNumber =
                            random.nextInt(filteredComments.length) + 1;
                        randomFilteredComments
                            .add(filteredComments[randomNumber]);
                      }
                      setState(() {});
                    },
                    child: Text(
                      'Show new $selectedCommentsCount random comments',
                    ),
                  ),
                const SizedBox(
                  height: 30,
                ),
                if (showFilteredComments)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: selectedCommentsCount,
                    itemBuilder: (context, index) => ListTile(
                      key: ValueKey(
                        randomFilteredComments[index]!.authorProfileImageUrl!,
                      ),
                      leading: ExtendedImage.network(
                        randomFilteredComments[index]!.authorProfileImageUrl!,
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
                      title: Text(randomFilteredComments[index]!.text!),
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
