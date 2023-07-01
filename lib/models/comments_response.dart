import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/page_info.dart';

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
