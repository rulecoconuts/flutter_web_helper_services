import 'package:json_annotation/json_annotation.dart';

abstract class ApiHalEntity {
  @JsonKey(name: "_links")
  final Map<String, dynamic>? links = {};
}
