class Comment {
  Comment({
    this.authorChannel,
    this.authorName,
    this.authorProfileImageUrl,
    this.createdAt,
    this.likeCount,
    this.text,
    this.updatedAt,
  });
  String? text;
  String? authorName;
  String? authorChannel;
  String? authorProfileImageUrl;
  int? likeCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        text: json["snippet"]["topLevelComment"]["snippet"]["textOriginal"]
            as String?,
        authorName: json["snippet"]["topLevelComment"]["snippet"]
            ["authorDisplayName"] as String?,
        authorChannel: json["snippet"]["topLevelComment"]["snippet"]
            ["authorChannelUrl"] as String?,
        authorProfileImageUrl: json["snippet"]["topLevelComment"]["snippet"]
            ["authorProfileImageUrl"] as String?,
        likeCount:
            json["snippet"]["topLevelComment"]["snippet"]["likeCount"] as int?,
        createdAt: DateTime.tryParse(
          '${json["snippet"]["topLevelComment"]["snippet"]["publishedAt"]}',
        ),
        updatedAt: DateTime.tryParse(
          '${json["snippet"]["topLevelComment"]["snippet"]["updatedAt"]}',
        ),
      );

  Map<String, dynamic> toJson() => {
        "authorName": authorName,
        "authorChannel": authorChannel,
        "authorProfileImageUrl": authorProfileImageUrl,
        "text": text,
        "likeCount": likeCount,
        "createdAt": createdAt,
        "updateAt": updatedAt,
      };
}
