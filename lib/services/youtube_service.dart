import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/comments_response.dart';
import 'package:youtube_comment_picker/models/video_information.dart';

BaseOptions ytbOptions = BaseOptions(
  baseUrl: 'https://youtube.googleapis.com/youtube/v3/',
  receiveDataWhenStatusError: true,
  connectTimeout: const Duration(seconds: 6),
  receiveTimeout: const Duration(seconds: 6),
);

final Dio dio = Dio(ytbOptions);

Logger log = Logger();

/// Provide either the video URL or the video id.
Future<List<Comment?>> getComments(String video, BuildContext context) async {
  final List<Comment?> comments = [];

  String videoId = '';

  if (video.length > 11) {
    videoId = video.after('?v=').before('&ab_channel')!;
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * .8,
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: const RoundedRectangleBorder(),
          content: const Text(
            'The URL provided is not a valid YouTube video URL!',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return [];
    }
  } else {
    videoId = video;
  }

  try {
    final response = await dio.get(
      'commentThreads',
      queryParameters: {
        "part": "snippet",
        "maxResults": "100",
        "videoId": videoId,
        "key": dotenv.env['API_KEY'],
      },
    );
    CommentsResponse res =
        CommentsResponse.fromJson(response.data as Map<String, dynamic>);

    comments.addAll(res.comments?.toList() ?? []);

    // While the response has [nextPageToken] parameter there are still pages with comments.
    // We keep on requesting and populating the comments list.
    while (res.nextPageToken != null) {
      final response = await dio.get(
        'commentThreads',
        queryParameters: {
          "part": "snippet",
          "maxResults": "100",
          "videoId": videoId,
          "pageToken": res.nextPageToken,
          "key": dotenv.env['API_KEY'],
        },
      );
      res = CommentsResponse.fromJson(response.data as Map<String, dynamic>);

      comments.addAll(res.comments?.toList() ?? []);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        shape: const RoundedRectangleBorder(),
        content: Text(
          '${e.message}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return comments;
}

Future<VideoInformation?> getVideoInformation(String video) async {
  String videoId = '';

  if (video.length > 11) {
    videoId = video.after('?v=').before('&ab_channel')!;
    if (video.isEmpty) {
      return null;
    }
  } else {
    videoId = video;
  }

  final response = await dio.get(
    'videos',
    queryParameters: {
      "part": "snippet,contentDetails,statistics",
      "id": videoId,
      "key": dotenv.env['API_KEY'],
    },
  );

  final VideoInformation videoInformation =
      VideoInformation.fromJson(response.data as Map<String, dynamic>);

  log.wtf(videoInformation.toJson());

  return videoInformation;
}
