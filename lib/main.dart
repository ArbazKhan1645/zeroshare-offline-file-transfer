import 'package:flutter/material.dart';
import 'package:zero_share/app/app_bootstrap.dart';
import 'package:zero_share/app/zero_share_app.dart';

void main() async {
  await AppBootstrap.initialize();
  runApp(const ZeroShareApp());
}
