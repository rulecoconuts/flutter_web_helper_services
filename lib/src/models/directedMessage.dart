import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(includeIfNull: false)
class DirectedMessage<U> {
  String label;
  U receipient;
  U sender;
  String message;

  DirectedMessage(this.label, this.sender, this.receipient, this.message);
}
