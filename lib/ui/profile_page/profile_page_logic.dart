// lib/ui/profile_page/profile_page_logic.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero_share/Widgets/avatar_selector_widget.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/constant.dart';

class ProfilePageLogic extends GetxController {
  final box = GetStorage();
  TextEditingController userNameController = TextEditingController();
  String? selectedAvatarImage;

  @override
  void onInit() {
    super.onInit();
    try {
      _loadUserData();
    } catch (e) {
      debugPrint('Error in ProfilePageLogic onInit: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      userNameController.text = box.read('username') ?? '';
      selectedAvatarImage = box.read('avatar');
      update();
      debugPrint('User data loaded successfully');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> selectAvatarImage(String? newImage) async {
    try {
      if (newImage != null) {
        selectedAvatarImage = newImage;
        await box.write('avatar', newImage);
        update();
        debugPrint('Avatar image selected: $newImage');
      }
    } catch (e) {
      debugPrint('Error selecting avatar image: $e');
    }
  }

  Future<void> saveUserName(String value) async {
    try {
      await box.write('username', value);
      update();
      debugPrint('Username saved: $value');
    } catch (e) {
      debugPrint('Error saving username: $e');
    }
  }

  Future<void> changeAvatar(BuildContext context) async {
    try {
      final selectedImage = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              borderRadius: BorderRadius.circular(24),
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            child: const AvatarSelectionDialog(),
          ),
        ),
      );

      if (selectedImage != null) {
        await selectAvatarImage(selectedImage);
      }
    } catch (e) {
      debugPrint('Error in changeAvatar: $e');
    }
  }

  Future<void> shareApp() async {
    try {
      const String appUrl = '';
      await SharePlus.instance.share(
        ShareParams(text: 'Check out this amazing app: \n$appUrl'),
      );
      debugPrint('App share initiated');
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  void viewPrivacyPolicy() {
    try {
      launchInBrowserView(Uri.parse(Constant.privacyPolicyURL));
    } catch (e) {
      debugPrint('Error viewing privacy policy: $e');
    }
  }

  Future<void> launchInBrowserView(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch $url');
      }
      debugPrint('URL launched successfully: $url');
    } catch (e) {
      debugPrint('Error launching URL: $e');

      rethrow;
    }
  }

  Future<void> requestReview() async {
    try {} catch (e) {
      debugPrint('Error requesting review: $e');
    }
  }

  @override
  void onClose() {
    try {
      userNameController.dispose();
      super.onClose();
      debugPrint('ProfilePageLogic closed');
    } catch (e) {
      debugPrint('Error in onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
