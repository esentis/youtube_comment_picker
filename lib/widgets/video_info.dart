import 'package:flutter/material.dart';
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
              child: Stack(
                children: [
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
                    child: Icon(
                      Icons.play_circle,
                      color: kColorRedYtb,
                      size: 50,
                    ),
                  ),
                ],
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
