import 'package:json_annotation/json_annotation.dart';

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
}

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

class SpringPageSortResult {
  bool sorted;
  bool empty;
  bool unsorted;

  SpringPageSortResult(
      {this.sorted = false, this.empty = false, this.unsorted = false});
}

/// Literal Page without assembler
class SpringPage<T> {
  final List<T> content = [];
  int number;
  int size;

  int totalElements;
  int totalPages;
  int numberOfElements;
  bool first;
  bool empty;
  bool last;
  SpringPageSortResult? sort;

  SpringPage(this.size, this.number,
      {this.totalElements = 0,
      this.totalPages = 0,
      this.numberOfElements = 0,
      this.first = false,
      this.empty = false,
      this.last = false,
      this.sort,
      List<T> content = const []}) {
    if (content != null) {
      this.content.addAll(content);
    }
  }
}
