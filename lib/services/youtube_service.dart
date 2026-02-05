import 'package:dio/dio.dart';
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
/// This method supports both regular YouTube videos and YouTube Shorts.
Future<List<Comment?>> getComments(String video) async {
  final comments = <Comment?>[];

  final videoId = _extractVideoId(video);
  if (videoId == null) {
    throw YoutubeServiceException(
      'The URL provided is not a valid YouTube video URL!',
    );
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
    throw YoutubeServiceException(
      e.message ?? 'Unable to load comments.',
      cause: e,
    );
  }
  return comments;
}

String? _extractVideoId(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  if (trimmed.length <= 11 && !trimmed.contains(' ')) {
    return trimmed;
  }

  if (trimmed.contains('/shorts/')) {
    var id = trimmed.after('/shorts/');
    if (id.contains('?')) {
      id = id.before('?');
    }
    if (id.contains('&')) {
      id = id.before('&');
    }
    return id.isEmpty ? null : id;
  }

  if (trimmed.contains('youtu.be/')) {
    var id = trimmed.after('youtu.be/');
    if (id.contains('?')) {
      id = id.before('?');
    }
    if (id.contains('&')) {
      id = id.before('&');
    }
    return id.isEmpty ? null : id;
  }

  if (trimmed.contains('?v=')) {
    var id = trimmed.after('?v=');
    if (id.contains('&')) {
      id = id.before('&');
    }
    return id.isEmpty ? null : id;
  }

  return null;
}

/// Exception thrown when a YouTube API request fails.
class YoutubeServiceException implements Exception {
  /// Creates an exception with a human-readable [message].
  YoutubeServiceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'YoutubeServiceException: $message';
  }
}

/// Retrieves the information of a YouTube video based on its ID or URL.
///
/// If the provided [video] parameter is a URL, it extracts the video ID from it.
/// Then, it makes an API request to retrieve the video information using the [videoId].
/// The API request includes the necessary query parameters such as "part", "id", and "key".
///
/// Returns the [VideoInformation] object containing the video's snippet, content details, and statistics.
/// If the video information cannot be retrieved, returns null.
Future<VideoInformation?> getVideoInformation(String video) async {
  String videoId = '';
  // Check if the input is a URL or a video ID
  if (video.length > 11) {
    // If it's a URL, extract the video ID
    if (video.contains('/shorts/')) {
      videoId = video.after('/shorts/');
      if (videoId.contains('?')) {
        videoId = videoId.before('?');
      }
    } else if (video.contains('?v=')) {
      videoId = video.after('?v=');
      if (videoId.contains('&')) {
        videoId = videoId.before('&');
      }
    }
  } else {
    videoId = video;
  }
  try {
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

    log.f(videoInformation.toJson());

    return videoInformation;
  } catch (e) {
    log.e(e);
    return null;
  }
}
