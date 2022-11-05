import 'package:json_annotation/json_annotation.dart';

part 'page.g.dart';

@JsonSerializable(includeIfNull: false)
class PageDetails {
  int size;
  int? totalElements;
  int? totalPages;
  int number;
  @JsonKey(ignore: true)
  final List<String> sortStrings = [];

  PageDetails(this.size, this.number,
      {this.totalElements,
      this.totalPages,
      List<String> sortStrings = const []}) {
    this.sortStrings.addAll(sortStrings);
  }

  String toUrlParams() {
    String pageParams = "page=$number&size=$size";
    for (String sortString in sortStrings) {
      pageParams += "&sort=$sortString";
    }

    return pageParams;
  }

  PageDetails next() {
    return PageDetails(size, number + 1,
        totalElements: totalElements, totalPages: totalPages);
  }

  PageDetails prev() {
    return PageDetails(size, number - 1,
        totalElements: totalElements, totalPages: totalPages);
  }

  factory PageDetails.fromJson(Map<String, dynamic> json) =>
      _$PageDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$PageDetailsToJson(this);
  Map<String, dynamic> toJsonWeb() => _$PageDetailsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class LiteralPageResult {
  /// Embedded data
  @JsonKey(name: "_embedded", required: true)
  final Map<String, dynamic> embedded = {};

  /// Pagination details
  @JsonKey(name: "page")
  PageDetails details;

  LiteralPageResult(this.details, {Map<String, dynamic>? embedded}) {
    if (embedded != null) {
      this.embedded.addAll(embedded);
    }
  }

  factory LiteralPageResult.fromJson(Map<String, dynamic> json) =>
      _$LiteralPageResultFromJson(json);
  Map<String, dynamic> toJson() => _$LiteralPageResultToJson(this);
  Map<String, dynamic> toJsonWeb() => _$LiteralPageResultToJson(this);
}

class Page<T> {
  final List<T> contents = [];

  PageDetails details;
  Page(this.details);
}

class PageCollection<T> {
  final List<Page> _pages = [];

  void add(Page<T> page) {}
}

/// Literal Page without assembler
@JsonSerializable(includeIfNull: false)
class LiteralPageResultNoAssembler {
  final List<dynamic> content = [];
  int number;
  int size;

  int? totalElements;
  int? totalPages;

  LiteralPageResultNoAssembler(this.size, this.number,
      {this.totalElements, this.totalPages, List<dynamic> content = const []}) {
    if (content != null) {
      this.content.addAll(content);
    }
  }

  factory LiteralPageResultNoAssembler.fromJson(Map<String, dynamic> json) =>
      _$LiteralPageResultNoAssemblerFromJson(json);

  Map<String, dynamic> toJson() => _$LiteralPageResultNoAssemblerToJson(this);
}
