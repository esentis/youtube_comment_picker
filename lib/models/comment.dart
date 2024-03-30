/// Represents a comment on YouTube.
class Comment {
  /// The text content of the comment.
  String? text;

  /// The name of the author of the comment.
  String? authorName;

  /// The channel URL of the author of the comment.
  String? authorChannel;

  /// The profile image URL of the author of the comment.
  String? authorProfileImageUrl;

  /// The number of likes the comment has received.
  int? likeCount;

  /// The date and time when the comment was created.
  DateTime? createdAt;

  /// The date and time when the comment was last updated.
  DateTime? updatedAt;

  /// TIf a comment has been hearted by the channel owner,
  /// the viewerRating field will have the value like.
  /// However, it's important to note that this field indicates
  /// the rating given by the currently authenticated user (if applicable),
  /// so it specifically shows if the authenticated user has liked the comment,
  /// not necessarily if the comment has been hearted by the channel owner.
  final String? viewerRating;

  /// Creates a new instance of the [Comment] class.
  Comment({
    this.authorChannel,
    this.authorName,
    this.authorProfileImageUrl,
    this.createdAt,
    this.likeCount,
    this.text,
    this.updatedAt,
    this.viewerRating,
  });

  /// Creates a new instance of the [Comment] class from a JSON object.
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
        viewerRating: json["snippet"]["topLevelComment"]["snippet"]
            ["viewerRating"] as String?,
        createdAt: DateTime.tryParse(
          '${json["snippet"]["topLevelComment"]["snippet"]["publishedAt"]}',
        ),
        updatedAt: DateTime.tryParse(
          '${json["snippet"]["topLevelComment"]["snippet"]["updatedAt"]}',
        ),
      );

  /// Converts the [Comment] object to a JSON object.
  Map<String, dynamic> toJson() => {
        "authorName": authorName,
        "authorChannel": authorChannel,
        "authorProfileImageUrl": authorProfileImageUrl,
        "text": text,
        "likeCount": likeCount,
        "viewerRating": viewerRating,
        "createdAt": createdAt,
        "updateAt": updatedAt,
      };
}
