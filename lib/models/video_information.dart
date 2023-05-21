class VideoInformation {
  final DateTime? publishedAt;
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? channelTitle;
  final List<dynamic>? tags;
  final String viewCount;

  VideoInformation({
    required this.publishedAt,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.channelTitle,
    required this.tags,
    required this.viewCount,
  });

  factory VideoInformation.fromJson(Map<String, dynamic> json) =>
      VideoInformation(
        publishedAt:
            DateTime.tryParse('${json['items'][0]['snippet']['publishedAt']}'),
        title: json['items'][0]['snippet']['title'] as String?,
        description: json['items'][0]['snippet']['description'] as String?,
        thumbnail: json['items'][0]['snippet']['thumbnails']['maxres']?['url']
            as String?,
        channelTitle: json['items'][0]['snippet']['channelTitle'] as String?,
        tags: json['items'][0]['snippet']['tags'] as List<dynamic>?,
        viewCount: json['items'][0]['statistics']['viewCount'] as String,
      );

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
