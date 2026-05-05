import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zero_share/utils/color.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations(_supportedOrientations);
    SystemChrome.setSystemUIOverlayStyle(_systemUiOverlayStyle);
  }

  static const List<DeviceOrientation> _supportedOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const SystemUiOverlayStyle _systemUiOverlayStyle =
      SystemUiOverlayStyle(
    statusBarColor: AppColor.colorTransparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
