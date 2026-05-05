// lib/ui/receive_page/receive_page_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_appbar.dart';

import 'package:zero_share/ui/receive_page/receive_page_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/utils/sizer_utils.dart';
import 'package:zero_share/Widgets/common_text.dart';
import 'package:zero_share/Widgets/static_radar.dart';

class ReceivePageView extends StatelessWidget {
  ReceivePageView({super.key});

  final logic = Get.find<ReceivePageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: GetBuilder<ReceivePageLogic>(
        builder: (controller) {
          return Column(
            children: [
              // Header Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    CommonText(
                      text: controller.isStartDiscovery.value == false
                          ? 'Tap to Start Scanning'
                          : controller.discoveredDevices.isEmpty
                              ? 'Searching for Devices...'
                              : 'Found ${controller.discoveredDevices.length} Device${controller.discoveredDevices.length > 1 ? 's' : ''}',
                      textColor: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSize.size_20,
                      textAlign: TextAlign.center,
                    ),
                    if (controller.isStartDiscovery.value == false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: CommonText(
                          text: 'Discover nearby devices to receive files',
                          textColor: AppColor.colorTextGreyLight,
                          fontWeight: FontWeight.w400,
                          fontSize: AppFontSize.size_12,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              // Found Devices List (Shows on top when devices found)
              if (controller.discoveredDevices.isNotEmpty)
                Expanded(
                  child: _buildDevicesList(controller),
                ),

              // Radar Animation (Shows when scanning or no devices)
              if (controller.discoveredDevices.isEmpty)
                Expanded(
                  child: Center(
                    child: controller.isStartDiscovery.value == false
                        ? _buildInitialRadar()
                        : _buildScanningRadar(controller),
                  ),
                ),

              // Bottom Controls
              _buildBottomControls(controller),
            ],
          );
        },
      ),
    );
  }

  // Initial Radar (Tap to start)
  Widget _buildInitialRadar() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          RadarWidget(
            onTap: () {
              logic.stopReceiving();
              logic.startReceiving();
            },
            size: 160.0,
            centerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.radar,
                    size: 60,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CommonText(
            text: 'Tap to Start Scanning',
            textColor: AppColor.colorTextGreyLight,
            fontWeight: FontWeight.w400,
            fontSize: AppFontSize.size_12,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Scanning Radar Animation
  Widget _buildScanningRadar(ReceivePageLogic controller) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Radar Rings
          AnimatedBuilder(
            animation: controller.radarController!,
            builder: (context, child) {
              return CustomPaint(
                painter: RadarPainter(controller.radarController!.value),
                child: const SizedBox(height: 320, width: 320),
              );
            },
          ),

          // Center Icon
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_find,
              size: 50,
              color: AppColor.primary,
            ),
          ),

          // Pulsing effect
          AnimatedBuilder(
            animation: controller.radarController!,
            builder: (context, child) {
              return Container(
                width: 120 + (controller.radarController!.value * 20),
                height: 120 + (controller.radarController!.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.primary.withValues(
                      alpha: 1 - controller.radarController!.value,
                    ),
                    width: 3,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Elegant Device List
  Widget _buildDevicesList(ReceivePageLogic controller) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: ListView.builder(
        key: ValueKey(controller.discoveredDevices.length),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: controller.discoveredDevices.length,
        itemBuilder: (context, index) {
          final device = controller.discoveredDevices[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.colorWhite,
                    AppColor.primaryLight.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => logic.connectToSender(device),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Device Avatar
                        Stack(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primary.withValues(alpha: 0.2),
                                    AppColor.primary.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColor.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  device.avatar.toLowerCase().contains('assets')
                                      ? device.avatar
                                      : 'assets/images/img_avatar_female_blue.png',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.colorWhite,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // Device Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      device.hostName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColor.colorBlack,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      device.os.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.wifi,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    device.ip,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${device.fileCount} files',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        // Connect Button
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColor.primary,
                                Color(0xFF45B649),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColor.colorWhite,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom Controls
  Widget _buildBottomControls(ReceivePageLogic controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.isStartDiscovery.value)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: logic.stopReceiving,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text(
                          'Stop Scanning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: AppColor.colorWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // QR Code Scanner Button
                if (!controller.isStartDiscovery.value)
                  OutlinedButton.icon(
                    onPressed: logic.openQRScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      side: const BorderSide(
                        color: AppColor.primary,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
              ],
            ),
          if (!controller.isStartDiscovery.value) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      logic.stopReceiving();
                      logic.startReceiving();
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text(
                      'Start Scanning',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.colorWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: AppColor.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // QR Code Scanner Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: logic.openQRScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Connect via QR Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  side: const BorderSide(color: AppColor.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Make sure both devices are on the same WiFi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Enhanced Radar Painter
class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = size.center(Offset.zero);

    // Draw multiple ripples with gradient effect
    for (int i = 0; i < 4; i++) {
      final double rippleProgress = (progress - (i * 0.25)).clamp(0.0, 1.0);
      final double opacity = (1 - rippleProgress).clamp(0.0, 1.0);
      final double radius = (size.width / 2) * rippleProgress;

      // Gradient colors
      paint.shader = RadialGradient(
        colors: [
          AppColor.primary.withValues(alpha: opacity * 0.8),
          AppColor.primary.withValues(alpha: opacity * 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // Draw static rings
    paint.shader = null;
    for (int i = 1; i <= 3; i++) {
      paint.color = AppColor.primary.withValues(alpha: 0.1);
      paint.strokeWidth = 1.5;
      canvas.drawCircle(center, (size.width / 6) * i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
