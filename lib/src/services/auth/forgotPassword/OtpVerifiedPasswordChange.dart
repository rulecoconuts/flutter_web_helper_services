import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class OtpVerifiedPasswordChange<U, O> {
  O otp;
  U user;
  String newPassword;
  OtpVerifiedPasswordChange(this.otp, this.user, this.newPassword);
}
