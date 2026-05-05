import 'package:flutter_test/flutter_test.dart';
import 'package:zero_share/app/zero_share_app.dart';

void main() {
  test('ZeroShareApp exposes the default English locale', () {
    expect(ZeroShareApp.defaultLocale.languageCode, 'en');
    expect(ZeroShareApp.defaultLocale.countryCode, 'US');
  });
}
