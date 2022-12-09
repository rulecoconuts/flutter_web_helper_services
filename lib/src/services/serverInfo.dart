import 'package:json_annotation/json_annotation.dart';

abstract class ServerInfo {
  String get url;
}

class SimpleServerInfo implements ServerInfo {
  final String _url;

  SimpleServerInfo(String url) : _url = url;

  @override
  String get url => _url;
}
