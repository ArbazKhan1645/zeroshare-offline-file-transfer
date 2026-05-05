import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';

ThemeData darkTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primary, // background (button) color
      foregroundColor: Colors.white, // foreground (text) color
    ),
  ),
  scaffoldBackgroundColor: AppColor.colorBlack,
  primaryColor: AppColor.primary,
  cardColor: AppColor.colorWhite,
  useMaterial3: true,
  scrollbarTheme: ScrollbarThemeData(
    thumbColor:
        WidgetStateProperty.all(AppColor.colorWhite.withValues(alpha: .3)),
  ),
  highlightColor: AppColor.colorTransparent,
  splashColor: AppColor.colorTransparent,
  checkboxTheme: CheckboxThemeData(
    side: const BorderSide(color: AppColor.primary),
    checkColor: WidgetStateProperty.all(AppColor.primary),
  ),
  colorScheme: const ColorScheme(
    inverseSurface: AppColor.primary,
    // for Icons
    tertiary: AppColor.colorRed,
    tertiaryContainer: AppColor.colorInputBackground,
    onTertiary: AppColor.colorWhite,
    brightness: Brightness.light,
    primary: AppColor.primary,
    onPrimary: AppColor.colorWhite,
    secondary: AppColor.primary,
    secondaryContainer: AppColor.primary,
    onSecondary: AppColor.primary,
    error: AppColor.colorRed,
    onError: AppColor.colorWhite,
    surface: AppColor.colorWhite,
    surfaceTint: AppColor.colorInputBackground,
    onSurface: AppColor.primary,
    onInverseSurface: AppColor.colorWhite,
    errorContainer: AppColor.colorRed,
    onSurfaceVariant: AppColor.primary,
    //for text
    surfaceContainerHighest: AppColor.colorInputBackground,
    inversePrimary: AppColor.colorWhite,
    onPrimaryContainer: AppColor.primary,
  ),
);
