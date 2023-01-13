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
        kind: json["kind"],
        etag: json["etag"],
        nextPageToken: json["nextPageToken"],
        pageInfo: PageInfo.fromJson(json["pageInfo"]),
        comments: json["items"] == null
            ? []
            : List<Comment?>.from(
                json["items"]!.map((x) => Comment.fromJson(x)),
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
        totalResults: json["totalResults"],
        resultsPerPage: json["resultsPerPage"],
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
        text: json["snippet"]["topLevelComment"]["snippet"]["textOriginal"],
        authorName: json["snippet"]["topLevelComment"]["snippet"]
            ["authorDisplayName"],
        authorChannel: json["snippet"]["topLevelComment"]["snippet"]
            ["authorChannelUrl"],
        authorProfileImageUrl: json["snippet"]["topLevelComment"]["snippet"]
            ["authorProfileImageUrl"],
        likeCount: json["snippet"]["topLevelComment"]["snippet"]["likeCount"],
        createdAt: DateTime.tryParse(
          json["snippet"]["topLevelComment"]["snippet"]["publishedAt"],
        ),
        updatedAt: DateTime.tryParse(
          json["snippet"]["topLevelComment"]["snippet"]["updatedAt"],
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
