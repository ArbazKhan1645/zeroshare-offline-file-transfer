import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:zero_share/localization/localizations_delegate.dart';
import 'package:zero_share/routes/app_pages.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/themes/app_theme.dart';
import 'package:zero_share/utils/constant.dart';

class ZeroShareApp extends StatelessWidget {
  const ZeroShareApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const Locale defaultLocale = Locale(
    Constant.languageEn,
    Constant.countryCodeEn,
  );

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          title: Constant.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: defaultLocale,
          fallbackLocale: defaultLocale,
          translations: AppLanguages(),
          getPages: AppPages.list,
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
