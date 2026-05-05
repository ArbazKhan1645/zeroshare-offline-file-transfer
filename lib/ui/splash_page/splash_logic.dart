import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero_share/controllers/file_controller.dart';
import 'package:zero_share/controllers/manager.dart';
import 'package:zero_share/generated/assets.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/utils/preference.dart';
import 'package:zero_share/utils/utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SplashScreenLogic extends GetxController {
  final RxBool isInitializing = true.obs;
  final RxString initializationStatus = 'Starting...'.obs;
  final RxDouble progress = 0.0.obs;

  Timer? _adLoadCheckTimer;

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  @override
  void onClose() {
    _adLoadCheckTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase and AdMob first

      // Step 1: Initialize GetStorage
      try {
        updateProgress(0.1, 'Initializing storage...');
        await GetStorage.init();
      } catch (e) {
        debugPrint('GetStorage initialization error: $e');

        updateProgress(0.1, 'Storage initialization failed');
      }

      // Step 2: Initialize Connection Manager
      try {
        updateProgress(0.15, 'Setting up connection...');
        Get.put(ConnectionManager(), permanent: true);
      } catch (e) {
        debugPrint('Connection Manager initialization error: $e');

        updateProgress(0.15, 'Connection setup failed');
      }

      // Step 3: Initialize Hive
      try {
        updateProgress(0.25, 'Setting up database...');
        await Hive.initFlutter();
        await Hive.openBox('appData');
      } catch (e) {
        debugPrint('Hive initialization error: $e');

        updateProgress(0.25, 'Database setup failed');
      }

      // Step 4: Setup default values
      try {
        updateProgress(0.35, 'Loading user data...');
        await _setupDefaultValues();
      } catch (e) {
        debugPrint('Setup default values error: $e');

        updateProgress(0.35, 'User data loading failed');
      }

      // Step 5: Register controllers with GetIt
      try {
        updateProgress(0.45, 'Registering services...');
        final getIt = GetIt.instance;
        if (!getIt.isRegistered<FileController>()) {
          getIt.registerSingleton<FileController>(FileController());
        }
      } catch (e) {
        debugPrint('GetIt registration error: $e');

        updateProgress(0.45, 'Service registration failed');
      }

      // Step 6: Configure Local TimeZone
      try {
        updateProgress(0.60, 'Configuring timezone...');
        await _configureLocalTimeZone();
      } catch (e) {
        debugPrint('Timezone configuration error: $e');

        updateProgress(0.60, 'Timezone configuration failed');
      }

      // Step 7: Initialize Shared Preference
      try {
        updateProgress(0.75, 'Loading preferences...');
        await Preference().instance();
      } catch (e) {
        debugPrint('Preference initialization error: $e');

        updateProgress(0.75, 'Preferences loading failed');
      }

      // Step 7.5: Update theme after preferences are loaded
      try {
        _updateAppTheme();
      } catch (e) {
        debugPrint('Theme update error: $e');
      }

      // Step 10: Complete initialization
      updateProgress(1.0, 'Ready!');

      // Navigate to next screen
      await _navigateToNextScreen();
    } catch (e) {
      // Handle any uncaught initialization errors
      debugPrint('Critical initialization error: $e');

      updateProgress(0.0, 'Initialization failed');

      await _navigateToNextScreen();
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _setupDefaultValues() async {
    try {
      final Box box = Hive.box('appData');

      if (box.get('username') == null) {
        try {
          final String hostname = Platform.localHostname;
          await box.put(
            'username',
            hostname.isNotEmpty ? '${hostname}_user' : 'User',
          );
        } catch (e) {
          debugPrint('Username setup error: $e');

          await box.put('username', 'User');
        }
      }

      if (box.get('avatar') == null) {
        try {
          await box.put('avatar', Assets.imagesImgAvatarFemaleBlue);
        } catch (e) {
          debugPrint('Avatar setup error: $e');
        }
      }
    } catch (e) {
      debugPrint('Setup default values error: $e');

      rethrow;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      if (kIsWeb || Platform.isLinux) {
        return;
      }

      tz.initializeTimeZones();

      try {
        final TimezoneInfo timeZone = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timeZone.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Timezone fetching error: $e');
      }
    } catch (e) {
      debugPrint('Timezone configuration error: $e');
    }
  }

  void updateProgress(double value, String status) {
    try {
      progress.value = value;
      initializationStatus.value = status;
    } catch (e) {
      debugPrint('Progress update error: $e');
    }
  }

  void _updateAppTheme() {
    try {
      Get.changeThemeMode(
        Utils.isLightTheme() ? ThemeMode.light : ThemeMode.dark,
      );
    } catch (e) {
      debugPrint('Theme update error: $e');
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final bool isGetStarted = Preference.shared.getIsGetStarted();
      final bool isIntroductionWithPlans =
          Preference.shared.getIsIntroductionWithPlans();

      if (isGetStarted && isIntroductionWithPlans) {
        await Get.offAllNamed(AppRoutes.dashboard);
      } else if (isGetStarted) {
        await Get.offAllNamed(AppRoutes.plans);
      } else {
        await Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');

      // Fallback navigation
      try {
        await Get.offAllNamed(AppRoutes.dashboard);
      } catch (fallbackError) {
        debugPrint('Fallback navigation error: $fallbackError');
      }
    }
  }
}
