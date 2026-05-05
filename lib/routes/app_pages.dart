import 'package:get/get.dart';
import 'package:zero_share/routes/app_routes.dart';
import 'package:zero_share/ui/connect_page/connect_page_binding.dart';
import 'package:zero_share/ui/connect_page/connect_page_view.dart';
import 'package:zero_share/ui/dashboard/dashboard_binding.dart';
import 'package:zero_share/ui/dashboard/dashboard_view.dart';
import 'package:zero_share/ui/home/home_binding.dart';
import 'package:zero_share/ui/home/home_view.dart';
import 'package:zero_share/ui/premium_plans_page/premium_plans_binding.dart';
import 'package:zero_share/ui/premium_plans_page/premium_plans_view.dart';
import 'package:zero_share/ui/privacy_policy/privacy_policy_binding.dart';
import 'package:zero_share/ui/privacy_policy/privacy_policy_view.dart';
import 'package:zero_share/ui/profile_page/profile_page_binding.dart';
import 'package:zero_share/ui/profile_page/profile_page_view.dart';
import 'package:zero_share/ui/qr_code_page/qr_code_binding.dart';
import 'package:zero_share/ui/qr_code_page/qr_code_view.dart';
import 'package:zero_share/ui/receive_page/receive_page_binding.dart';
import 'package:zero_share/ui/receive_page/receive_page_view.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_binding.dart';
import 'package:zero_share/ui/received_app_gallery/files_gallery_view.dart';
import 'package:zero_share/ui/receiving_progress_page/receiving_progress_binding.dart';
import 'package:zero_share/ui/receiving_progress_page/receiving_progress_view.dart';
import 'package:zero_share/ui/scanner_page/scanner_binding.dart';
import 'package:zero_share/ui/scanner_page/scanner_view.dart';
import 'package:zero_share/ui/send_file_page/send_file_binding.dart';
import 'package:zero_share/ui/send_file_page/send_file_view.dart';
import 'package:zero_share/ui/sending_progress_page/sending_progress_binding.dart';
import 'package:zero_share/ui/sending_progress_page/sending_progress_view.dart';
import 'package:zero_share/ui/splash_page/splash_binding.dart';
import 'package:zero_share/ui/splash_page/splash_view.dart';
import 'package:zero_share/ui/welcome_page/welcome_binding.dart';
import 'package:zero_share/ui/welcome_page/welcome_view.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> list = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashViewPage(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreenPage(),
      binding: WelcomeScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.plans,
      page: () => PremiumPlansView(),
      binding: PremiumPlansBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.connectPage,
      page: () => ConnectPageView(),
      binding: ConnectPageBinding(),
    ),
    GetPage(
      name: AppRoutes.profilePage,
      page: () => ProfilePageView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: AppRoutes.scannerPage,
      page: () => ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: AppRoutes.qrCodePage,
      page: () => QrCodeView(),
      binding: QrCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.sendFile,
      page: () => const SendFileView(),
      binding: SendFileBinding(),
    ),
    GetPage(
      name: AppRoutes.receivePage,
      page: () => ReceivePageView(),
      binding: ReceivePageBinding(),
    ),
    GetPage(
      name: AppRoutes.sendingProgressPage,
      page: () => const SendingProgressView(),
      binding: SendingProgressBinding(),
    ),
    GetPage(
      name: AppRoutes.receivingProgressPage,
      page: () => ReceivingProgressView(),
      binding: ReceivingProgressBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.receivedFilesGallery,
      page: () => FilesView(showAppBar: false),
      binding: FilesBinding(),
    ),
  ];
}
