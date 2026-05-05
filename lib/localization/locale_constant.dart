import 'dart:ui';

import 'package:zero_share/utils/constant.dart';

import 'package:zero_share/utils/preference.dart';

Locale getLocale() {
  final String languageCode =
      Preference.shared.getString(Preference.selectedLanguage) ??
          Constant.languageEn;
  final String countryCode =
      Preference.shared.getString(Preference.selectedCountryCode) ??
          Constant.countryCodeEn;

  return _locale(languageCode, countryCode);
}

Locale _locale(String languageCode, String countryCode) {
  return languageCode.isNotEmpty
      ? Locale(languageCode, countryCode)
      : const Locale(Constant.languageEn, Constant.countryCodeEn);
}
