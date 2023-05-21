class CommentsResponse {
  CommentsResponse({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.pageInfo,
    this.comments,
  });

  String? kind;
  String? etag;
  String? nextPageToken;
  PageInfo? pageInfo;
  List<Comment?>? comments;

  factory CommentsResponse.fromJson(Map<String, dynamic> json) =>
      CommentsResponse(
        kind: json["kind"] as String?,
        etag: json["etag"] as String?,
        nextPageToken: json["nextPageToken"] as String?,
        pageInfo: (json["pageInfo"] != null
            ? PageInfo.fromJson(json["pageInfo"] as Map<String, dynamic>)
            : null),
        comments: json["items"] == null
            ? []
            : List<Comment?>.from(
                (json["items"] as List)
                    .map((x) => Comment.fromJson(x as Map<String, dynamic>)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "nextPageToken": nextPageToken,
        "pageInfo": pageInfo!.toJson(),
        "comments": comments == null
            ? []
            : List<Comment>.from(comments!.map((x) => x!.toJson())),
      };
}

class PageInfo {
  PageInfo({
    this.totalResults,
    this.resultsPerPage,
  });

  int? totalResults;
  int? resultsPerPage;

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults: json["totalResults"] as int?,
        resultsPerPage: json["resultsPerPage"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "totalResults": totalResults,
        "resultsPerPage": resultsPerPage,
      };
}

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
