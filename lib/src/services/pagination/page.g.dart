// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageDetails _$PageDetailsFromJson(Map<String, dynamic> json) {
  return PageDetails(
    json['size'] as int,
    json['number'] as int,
    totalElements: json['totalElements'] as int?,
    totalPages: json['totalPages'] as int?,
  );
}

Map<String, dynamic> _$PageDetailsToJson(PageDetails instance) {
  final val = <String, dynamic>{
    'size': instance.size,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('totalElements', instance.totalElements);
  writeNotNull('totalPages', instance.totalPages);
  val['number'] = instance.number;
  return val;
}

LiteralPageResult _$LiteralPageResultFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['_embedded']);
  return LiteralPageResult(
    PageDetails.fromJson(json['page'] as Map<String, dynamic>),
    embedded: json['_embedded'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$LiteralPageResultToJson(LiteralPageResult instance) =>
    <String, dynamic>{
      '_embedded': instance.embedded,
      'page': instance.details,
    };

LiteralPageResultNoAssembler _$LiteralPageResultNoAssemblerFromJson(
    Map<String, dynamic> json) {
  return LiteralPageResultNoAssembler(
    json['size'] as int,
    json['number'] as int,
    totalElements: json['totalElements'] as int?,
    totalPages: json['totalPages'] as int?,
    content: json['content'] as List<dynamic>,
  );
}

Map<String, dynamic> _$LiteralPageResultNoAssemblerToJson(
    LiteralPageResultNoAssembler instance) {
  final val = <String, dynamic>{
    'content': instance.content,
    'number': instance.number,
    'size': instance.size,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('totalElements', instance.totalElements);
  writeNotNull('totalPages', instance.totalPages);
  return val;
}
