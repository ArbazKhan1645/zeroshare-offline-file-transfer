// lib/ui/connect_page/connect_page_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero_share/Widgets/common_appbar.dart';
import 'package:zero_share/Widgets/static_radar.dart';

import 'package:zero_share/ui/connect_page/connect_page_logic.dart';
import 'package:zero_share/utils/color.dart';

class ConnectPageView extends StatelessWidget {
  ConnectPageView({super.key});

  final logic = Get.find<ConnectPageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        actionWidget: IconButton(
          onPressed: () {
            logic.navigateToQRScanner();
          },
          icon: const Icon(Icons.qr_code, color: AppColor.colorBlack),
        ),
        onBackTap: () {
          logic.stopDiscovery();
          Get.back();
        },
      ),
      body: GetBuilder<ConnectPageLogic>(
        builder: (controller) {
          return Column(
            children: [
              // Header
              _buildHeader(controller),

              // Room Mode Toggle
              _buildRoomModeToggle(controller),

              // Content
              Expanded(
                child: controller.isRoomMode.value
                    ? _buildRoomStarting(controller)
                    : controller.discoveredRooms.isEmpty
                        ? _buildRadarSection(controller)
                        : _buildDevicesList(controller),
              ),

              // Bottom Controls
              _buildBottomControls(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ConnectPageLogic controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            controller.isRoomMode.value
                ? 'Start Transfer Room'
                : controller.isStartDiscovery.value
                    ? 'Select Room to Join'
                    : 'Connect Room to Transfers',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.colorBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            controller.isRoomMode.value
                ? 'Start a room to send and receive files'
                : 'Scan for devices or start a room',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // NEW: Room Mode Toggle
  Widget _buildRoomModeToggle(ConnectPageLogic controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.isRoomMode.value) {
                  controller.toggleRoomMode();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !controller.isRoomMode.value
                      ? AppColor.colorWhite
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !controller.isRoomMode.value
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: !controller.isRoomMode.value
                          ? AppColor.primary
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Find Devices',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !controller.isRoomMode.value
                            ? AppColor.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!controller.isRoomMode.value) {
                  controller.toggleRoomMode();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.isRoomMode.value
                      ? AppColor.colorWhite
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: controller.isRoomMode.value
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.meeting_room_rounded,
                      color: controller.isRoomMode.value
                          ? AppColor.primary
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Room',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.isRoomMode.value
                            ? AppColor.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Room Starting State
  Widget _buildRoomStarting(ConnectPageLogic controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.room_outlined,
              size: 80,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 30),
          if (controller.isStartingRoom.value)
            const CircularProgressIndicator(
              color: AppColor.primary,
            )
          else
            const Text(
              'Tap Start Room below',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.colorTextGreyLight,
              ),
            ),
        ],
      ),
    );
  }

  // Elegant Devices List
// In _buildDevicesList method, replace with this:
  Widget _buildDevicesList(ConnectPageLogic controller) {
    return Column(
      children: [
        // // Rooms Found Header
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 20),
        //   padding: const EdgeInsets.all(15),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [
        //         AppColor.primary.withValues(alpha: 0.1),
        //         AppColor.primary.withValues(alpha: 0.05),
        //       ],
        //     ),
        //     borderRadius: BorderRadius.circular(15),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       const Icon(Icons.meeting_room_rounded,
        //           color: AppColor.primary),
        //       const SizedBox(width: 12),
        //       Text(
        //         '${controller.discoveredRooms.length} Room${controller.discoveredRooms.length > 1 ? 's' : ''} Found',
        //         style: const TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.bold,
        //           color: AppColor.primary,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // const SizedBox(height: 15),

        // Rooms List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.discoveredRooms.length,
            itemBuilder: (context, index) {
              final room = controller.discoveredRooms[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.colorWhite,
                        AppColor.primaryLight.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        blurRadius: 15,
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
                      onTap: () => controller.joinRoom(room),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            // Room Icon
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primary.withValues(alpha: 0.2),
                                    AppColor.primary.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.meeting_room_rounded,
                                color: AppColor.primary,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 18),

                            // Room Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room.hostName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: AppColor.colorBlack,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        room.hostIP,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Join Button
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColor.primary,
                                    Color(0xFF45B649),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColor.primary.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
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
        ),
      ],
    );
  }

  // Radar Section (Shows when no devices or scanning)
  Widget _buildRadarSection(ConnectPageLogic controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: controller.isStartDiscovery.value == false
            ? _buildInitialRadar()
            : _buildScanningRadar(controller),
      ),
    );
  }

  // Initial Radar (Tap to start)
  Widget _buildInitialRadar() {
    return Column(
      children: [
        RadarWidget(
          onTap: () {
            logic.startDiscovery();
          },
          size: 180.0,
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
        const SizedBox(height: 15),
        const Text(
          'TAP TO SCAN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // Scanning Radar with Animation
  Widget _buildScanningRadar(ConnectPageLogic controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated Radar Rings
        AnimatedBuilder(
          animation: controller.radarController!,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedRadarPainter(controller.radarController!.value),
              child: const SizedBox(height: 320, width: 320),
            );
          },
        ),

        // Center Icon with Pulse
        AnimatedBuilder(
          animation: controller.radarController!,
          builder: (context, child) {
            return Container(
              width: 80 + (controller.radarController!.value * 10),
              height: 80 + (controller.radarController!.value * 10),
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

        Container(
          padding: const EdgeInsets.all(20),
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
            size: 40,
            color: AppColor.primary,
          ),
        ),

        // Scanning Text
        Positioned(
          bottom: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  return Text(
                    'Scanning... ${logic.discoveryTimeLeft.value}s',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(ConnectPageLogic controller) {
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.isRoomMode.value) ...[
            // Start Room Button
            ElevatedButton.icon(
              onPressed:
                  controller.isStartingRoom.value ? null : controller.startRoom,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                controller.isStartingRoom.value
                    ? 'Starting Room...'
                    : 'Start Room',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ] else ...[
            // Scan Button
            if (controller.isStartDiscovery.value)
              ElevatedButton.icon(
                onPressed: controller.stopDiscovery,
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: controller.startDiscovery,
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// Enhanced Radar Painter with Gradient
class EnhancedRadarPainter extends CustomPainter {
  final double progress;

  EnhancedRadarPainter(this.progress);

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

      paint.shader = RadialGradient(
        colors: [
          AppColor.primary.withValues(alpha: opacity * 0.8),
          AppColor.primary.withValues(alpha: opacity * 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // Draw static guide rings
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
