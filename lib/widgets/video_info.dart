import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/video_information.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoInfo extends StatelessWidget {
  const VideoInfo({
    super.key,
    required this.videoInfo,
    required this.ytbController,
  });

  final VideoInformation? videoInfo;
  final YoutubePlayerController? ytbController;
  String _printDuration(Duration duration) {
    final String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(60).abs());
    final String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: YoutubePlayer(
                      controller: ytbController!,
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 150,
                height: 100,
                child: Stack(
                  children: [
                    if (videoInfo!.thumbnail != null)
                      ImageNetwork(
                        image: videoInfo!.thumbnail!,
                        width: 150,
                        height: 100,
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: (videoInfo?.duration.inSeconds ?? 0) <= 60
                          ? Center(
                              child: SvgPicture.asset(
                                'assets/shorts.svg',
                                height: 35,
                                width: 35,
                              ),
                            )
                          : Icon(
                              Icons.play_circle,
                              color: kColorRedYtb,
                              size: 35,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 150,
                        child: Center(
                          child: Text(
                            _printDuration(videoInfo!.duration),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                videoInfo!.title!,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    '${NumberFormat('#,###,000').format(videoInfo?.viewCount.toInt())} views',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '   ${DateFormat('MMM d, yyyy').format(videoInfo!.publishedAt!)}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
