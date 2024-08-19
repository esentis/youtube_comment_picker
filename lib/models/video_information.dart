/// Represents information about a video.
class VideoInformation {
  final DateTime? publishedAt;
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? channelTitle;
  final List<dynamic>? tags;
  final String viewCount;

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
  });

  /// Constructs a [VideoInformation] object from a JSON map.
  ///
  /// The [json] parameter is a JSON map representing the video information.
  factory VideoInformation.fromJson(Map<String, dynamic> json) {
    final isNotEmpty = (json['items'] as List).isNotEmpty;
    return VideoInformation(
      publishedAt: isNotEmpty
          ? DateTime.tryParse('${json['items'][0]['snippet']['publishedAt']}')
          : null,
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
