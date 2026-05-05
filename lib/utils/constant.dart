import 'package:flutter/material.dart';

class Constant {
  static const appTitle = 'ZeroShare';
  static const languageEn = 'en';
  static const countryCodeEn = 'US';
  static const fontFamilyNunito = 'Nunito';
  static const fontFamilyPoppins = 'Poppins';
  static const fontFamilyNunitoSans = 'NunitoSans';
  static const fontFamilyRighteous = 'Righteous';
  static const fontFamilyLexendDeca = 'LexendDeca';
  static const validationTypeEmail = 'Email';
  static const validationTypePhone = 'Phone';
  static const validationTypePassword = 'Password';
  static const validationTypeUserName = 'UserName';
  static const validationTypeBirthDate = 'BirthDate';
  static const validationTypeEmpty = 'Empty';
  static const idUserNameInput = 'idUserNameInput';

  //Username
  static const userName = 'userName';

  //avatar image
  static const avatarImg = 'avatarImg';

  //
  String?
  selectedEndpointId; // Nullable to handle the case when no endpoint is selected

  static const boolValueTrue = true;
  static const boolValueFalse = false;

  static const appThemeLight = 'LIGHT';
  static const appThemeDark = 'DARK';

  // static String privacyPolicyURL = "Add your privacy policy link here";
  static String privacyPolicyURL = '';

  static String aboutUsURL = 'Add your About Us Url link here';

  /// Terms & condition URL
  static const termsAndConditionURL = 'Add your terms and condition link here';

  static String googlePlayIdentifier = 'Add your google Play Identifier here';

  static String getAsset() => 'assets/';

  static String getAssetIcons() => 'assets/icons/';

  static String getAssetItem() => 'assets/item/';

  static String getAssetBackground() => 'assets/background/';

  static String getAssetImage() => 'assets/images/';

  /// <<===================>> ****** Widget Id's for refresh in GetX ****** <<===================>>
}

class ColorPicker {
  Color color;
  bool isSelected;
  int indexColor;

  ColorPicker({
    required this.indexColor,
    required this.color,
    required this.isSelected,
  });
}
