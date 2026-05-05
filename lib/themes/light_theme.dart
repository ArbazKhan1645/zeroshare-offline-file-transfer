import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';

ThemeData lightTheme = ThemeData(
  unselectedWidgetColor: AppColor.primary,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primary, // background (button) color
      foregroundColor: Colors.white, // foreground (text) color
    ),
  ),
  tabBarTheme: TabBarThemeData(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateProperty.all(Colors.white),
  ),
  // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
  scaffoldBackgroundColor: AppColor.colorWhite,
  cardColor: AppColor.colorWhite,
  primaryColor: AppColor.primary,
  useMaterial3: true,
  // timePickerTheme: _timePickerTheme,
  // datePickerTheme: _datePickerTheme,
  scrollbarTheme: ScrollbarThemeData(
    thumbColor:
        WidgetStateProperty.all(AppColor.colorBlack.withValues(alpha: .3)),
  ),
  highlightColor: AppColor.colorTransparent,
  splashColor: AppColor.colorTransparent,
  checkboxTheme: CheckboxThemeData(
    side: const BorderSide(color: AppColor.primary),
    checkColor: WidgetStateProperty.all(AppColor.colorRed),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      // active
      if (states.contains(WidgetState.selected)) {
        return AppColor.colorGreyDark.withValues(alpha: 0.2);
      }
      // inactive
      return AppColor.colorGreyDark.withValues(alpha: 0.2);
    }),
  ),
  colorScheme: const ColorScheme(
    inverseSurface: AppColor.colorWhite,
    // for Icons
    tertiary: AppColor.colorInputBackground,
    tertiaryContainer: AppColor.colorInputBackground,
    onTertiary: AppColor.colorYellowDark,
    brightness: Brightness.light,
    primary: AppColor.primary,
    primaryContainer: AppColor.primary,
    onPrimary: AppColor.colorWhite,
    secondary: AppColor.colorBlack,
    secondaryContainer: AppColor.primary,
    onSecondary: AppColor.colorBlack,
    error: AppColor.colorRed,
    onError: AppColor.colorRed,
    surface: AppColor.colorGreyDark,
    onSurface: AppColor.colorWhite,
    surfaceTint: AppColor.colorGreyLight,
    onInverseSurface: AppColor.colorWhite,
    errorContainer: AppColor.colorRed,
    onSurfaceVariant: AppColor.colorWhite,
    //for text light or white
    surfaceContainerHighest: AppColor.colorWhite,
    inversePrimary: AppColor.colorWhite,
    onPrimaryContainer: AppColor.primary,
  ),
);
