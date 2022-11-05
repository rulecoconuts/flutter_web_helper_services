import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class EmailValidationRequest<U, O> {
  U user;
  O otp;
  EmailValidationRequest({required this.user, required this.otp});
}
