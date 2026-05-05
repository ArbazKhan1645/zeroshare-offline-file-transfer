// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/constant.dart';
import 'package:zero_share/utils/preference.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:intl/intl.dart' as intl;

class Utils {
  //static AudioPlayer audioPlayer = AudioPlayer();

  static Future<bool?> showToast([BuildContext? context, String? msg]) {
    return Fluttertoast.showToast(
      msg: msg!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      textColor: AppColor.colorWhite,
      fontSize: AppFontSize.size_13,
    );
  }

  static bool isFirstTimeOpenApp() {
    return Preference.shared.getBool(Preference.isFirstTimeOpenApp) ??
        Constant.boolValueTrue;
  }

  static String decimalNumberFormat(int number) {
    return intl.NumberFormat.decimalPattern().format(number);
  }

  // static playAudio(String audio) async {
  //   audioPlayer.play(AssetSource(audio), volume: 1);
  //   audioPlayer.setReleaseMode(ReleaseMode.loop);
  // }

  static Map<String, Color> colorList = const {
    'orange': Color(0XFFED4A0D),
    'violet': Color(0XFF6E3DFA),
    'red': Color(0XFFE30A0A),
    'green': Color(0XFF24DA0F),
    'cyan': Color(0XFF00CFDB),
    'pink': Color(0XFFCC00C1),
    'blue': Color(0XFF4253FF),
    'yellow': Color(0XFFF6D913),
  };
  static List<Color> colorPickerList = const [
    Color(0XFF00C2AF),
    Color(0XFF00B500),
    Color(0XFF7FD200),
    Color(0XFFFEEF00),
    Color(0XFFFAC712),
    Color(0XFFF69F23),
    Color(0XFF97979A),
    Color(0XFFFF2600),
    Color(0XFFD2298E),
    Color(0XFF7421B0),
    Color(0XFF3A48BA),
    Color(0XFF006FC4),
    Color(0XFFBC2B13),
    Color(0XFFFB6312),
  ];

  static void unFocusKeyboard() {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  static void showHideStatusBar({bool isHide = true}) {
    if (!Platform.isIOS) {
      if (isHide) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      } else {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      }
    }
  }

  static bool isLightTheme() {
    if (Preference.shared.getAppTheme() == Constant.appThemeLight) {
      return true;
    } else {
      return false;
    }
  }
}
