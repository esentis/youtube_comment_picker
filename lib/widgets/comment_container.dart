// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/services/youtube_service.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.comment,
    required this.highlightText,
  });

  final Comment comment;
  final String highlightText;
  void saveUint8ListAsFile(
    Uint8List uint8List,
    String fileName,
    String mimeType,
  ) {
    // Create a blob from the Uint8List
    final blob = html.Blob([uint8List], mimeType);

    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element and set its properties
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..style.display = 'none';

    // Add the anchor to the document body, click it, and then remove it
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    // Revoke the URL to free up memory
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final terms = highlightText.split(' ');
    final ScreenshotController controller = ScreenshotController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Screenshot(
              controller: controller,
              child: Container(
                decoration: BoxDecoration(
                  color: kColorSurface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(14.0),
                  ),
                  border: Border.all(
                    color: kColorBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  key: ValueKey(
                    comment.authorProfileImageUrl!,
                  ),
                  leading: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        log.f(comment.authorChannel);
                        kLaunchUrl(
                          comment.authorChannel ?? '',
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(360),
                        child: CachedNetworkImage(
                          imageUrl: comment.authorProfileImageUrl!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (c, url) => const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (c, url, e) => Image.network(
                            'https://i.imgur.com/qV26MhU.png',
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
                        terms: terms,
                        text: comment.text!,
                        textStyle: const TextStyle(
                          color: kColorText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textStyleHighlight: const TextStyle(
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
                            color: kColorTextMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            comment.likeCount!.toString(),
                            style: const TextStyle(
                              color: kColorTextMuted,
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
                            color: kColorText,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if ((comment.createdAt
                                    ?.difference(DateTime.now())
                                    .inDays ??
                                0) <
                            365)
                          Text(
                            timeago.format(comment.createdAt!),
                            style: const TextStyle(
                              color: kColorTextMuted,
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            DateFormat.yMMMd().format(
                              comment.createdAt!,
                            ),
                            style: const TextStyle(
                              color: kColorTextMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                controller.capture().then(
                  (image) {
                    saveUint8ListAsFile(
                      image!,
                      '${comment.text?.removeSpecial}.png',
                      'image/png',
                    );
                  },
                );
              },
              child: const Icon(
                Icons.download,
                color: kColorTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
