import 'package:get/get.dart';

import 'package:zero_share/localization/languages/language_en.dart';

class AppLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,

        //Add your new language here
      };
}

final List<LanguageModel> languages = [
  LanguageModel('🇺🇸', 'English (English)', 'en', 'US'),

  //Add your new language here
];

class LanguageModel {
  LanguageModel(
    this.symbol,
    this.language,
    this.languageCode,
    this.countryCode,
  );

  String language;
  String symbol;
  String countryCode;
  String languageCode;
}
