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
