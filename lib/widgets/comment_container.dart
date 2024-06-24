import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comment.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.comment,
    required this.highlightText,
  });

  final Comment comment;
  final String highlightText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        key: ValueKey(
          comment.authorProfileImageUrl!,
        ),
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              kLaunchUrl(
                comment.authorChannel ?? '',
              );
            },
            child: SizedBox(
              height: 50,
              width: 50,
              child: ImageNetwork(
                image: comment.authorProfileImageUrl!,
                height: 50,
                width: 50,
                fitAndroidIos: BoxFit.fill,
                onLoading: LottieBuilder.asset(
                  'assets/loading.json',
                  height: 100,
                ),
                onError: Image.network(
                  'https://i.imgur.com/qV26MhU.png',
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubstringHighlight(
              textAlign: TextAlign.start,
              text: comment.text!,
              term: highlightText,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textStyleHighlight: TextStyle(
                color: kColorRedYtb,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_off_alt,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  comment.likeCount!.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Text(
                comment.authorName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              if ((comment.createdAt?.difference(DateTime.now()).inDays ?? 0) <
                  365)
                Text(
                  timeago.format(comment.createdAt!),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                )
              else
                Text(
                  DateFormat.yMMMd().format(
                    comment.createdAt!,
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
