/// Represents information about a video.
class VideoInformation {
  final DateTime? publishedAt;
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? channelTitle;
  final List<dynamic>? tags;
  final String viewCount;
  final Duration duration;

  /// Constructs a [VideoInformation] object.
  ///
  /// The [publishedAt], [title], [description], [thumbnail], [channelTitle],
  /// [tags], and [viewCount] parameters are required.
  VideoInformation({
    required this.publishedAt,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.channelTitle,
    required this.tags,
    required this.viewCount,
    required this.duration,
  });

  /// Helper function to parse ISO 8601 duration (e.g., PT1M30S) into a Dart Duration.
  static Duration parseISO8601Duration(String iso8601Duration) {
    final RegExp regex = RegExp(r'PT(\d+M)?(\d+S)?');
    final Match match = regex.firstMatch(iso8601Duration)!;

    int minutes = 0;
    int seconds = 0;

    if (match.group(1) != null) {
      minutes = int.parse(match.group(1)!.replaceAll('M', ''));
    }
    if (match.group(2) != null) {
      seconds = int.parse(match.group(2)!.replaceAll('S', ''));
    }

    return Duration(minutes: minutes, seconds: seconds);
  }

  /// Constructs a [VideoInformation] object from a JSON map.
  ///
  /// The [json] parameter is a JSON map representing the video information.
  factory VideoInformation.fromJson(Map<String, dynamic> json) {
    final isNotEmpty = (json['items'] as List).isNotEmpty;
    return VideoInformation(
      publishedAt: isNotEmpty
          ? DateTime.tryParse('${json['items'][0]['snippet']['publishedAt']}')
          : null,
      duration: parseISO8601Duration(
        json['items'][0]['contentDetails']['duration'] as String,
      ),
      title:
          isNotEmpty ? json['items'][0]['snippet']['title'] as String? : null,
      description: isNotEmpty
          ? json['items'][0]['snippet']['description'] as String?
          : null,
      thumbnail: isNotEmpty
          ? (json['items'][0]['snippet']['thumbnails']['maxres']?['url']
              as String?)
          : null,
      channelTitle: isNotEmpty
          ? json['items'][0]['snippet']['channelTitle'] as String?
          : null,
      tags: isNotEmpty
          ? json['items'][0]['snippet']['tags'] as List<dynamic>?
          : null,
      viewCount: isNotEmpty
          ? json['items'][0]['statistics']['viewCount'] as String
          : '',
    );
  }

  /// Converts the [VideoInformation] object to a JSON map.
  ///
  /// Returns a JSON map representing the video information.
  Map<String, dynamic> toJson() => {
        "title": title,
        "publishedAt": publishedAt,
        "description": description,
        "thumbnail": thumbnail,
        "channelTitle": channelTitle,
        "tags": tags?.map((e) => e),
        "viewCount": viewCount,
      };
}
