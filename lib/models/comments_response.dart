import 'package:youtube_comment_picker/models/comment.dart';
import 'package:youtube_comment_picker/models/page_info.dart';

/// Represents the response object for retrieving comments.
class CommentsResponse {
  /// Creates a new instance of [CommentsResponse].
  CommentsResponse({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.pageInfo,
    this.comments,
  });

  /// The type of the API resource.
  String? kind;

  /// The ETag of the API response.
  String? etag;

  /// The token for the next page of results.
  String? nextPageToken;

  /// Information about the page of results.
  PageInfo? pageInfo;

  /// The list of comments.
  List<Comment?>? comments;

  /// Creates a new instance of [CommentsResponse] from a JSON map.
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

  /// Converts this [CommentsResponse] instance to a JSON map.
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
