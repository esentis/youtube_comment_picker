/// Represents the page information for a list of results.
class PageInfo {
  PageInfo({
    this.totalResults,
    this.resultsPerPage,
  });

  /// The total number of results.
  int? totalResults;

  /// The number of results per page.
  int? resultsPerPage;

  /// Creates a [PageInfo] instance from a JSON object.
  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults: json["totalResults"] as int?,
        resultsPerPage: json["resultsPerPage"] as int?,
      );

  /// Converts the [PageInfo] instance to a JSON object.
  Map<String, dynamic> toJson() => {
        "totalResults": totalResults,
        "resultsPerPage": resultsPerPage,
      };
}
