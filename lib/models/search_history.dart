class SearchHistoryItem {
  SearchHistoryItem({
    required this.videoId,
    required this.title,
    required this.query,
  });

  final String videoId;
  final String title;
  final String query;

  String get displayTitle => title.isNotEmpty ? title : videoId;

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'query': query,
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      query: json['query'] as String? ?? '',
    );
  }
}
