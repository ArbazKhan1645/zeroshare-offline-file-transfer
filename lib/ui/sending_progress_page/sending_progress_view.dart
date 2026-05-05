// lib/ui/sending_progress_page/sending_progress_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:zero_share/controllers/manager.dart';
import 'package:zero_share/controllers/status_widget.dart';
import 'package:zero_share/ui/sending_progress_page/sending_progress_logic.dart';
import 'package:zero_share/utils/color.dart';
import 'package:zero_share/Widgets/common_appbar.dart';

class SendingProgressView extends StatefulWidget {
  const SendingProgressView({super.key});

  @override
  State<SendingProgressView> createState() => _SendingProgressViewState();
}

class _SendingProgressViewState extends State<SendingProgressView>
    with TickerProviderStateMixin {
  final controller = Get.put(SendingProgressLogic());
  final connManager = ConnectionManager.instance;

  late AnimationController _rocketController;
  late AnimationController _pulseController;
  late Animation<double> _rocketAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rocket floating animation
    _rocketController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rocketAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInOut),
    );

    // Pulse animation for waiting state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didpop, p) async =>
          await _showExitConfirmation(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: CommonAppBar(
          onBackTap: () async {
            controller.stopServer();
            Get.until((e) => e.isFirst);
          },
        ),
        body: GetBuilder<SendingProgressLogic>(
          builder: (logic) {
            if (!logic.isServerRunning.value) {
              return _buildLoadingState();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Connection Status Widget
                  const ConnectionStatusWidget(),

                  const SizedBox(height: 20),

                  // Animated Rocket/Status Section
                  _buildAnimatedStatusSection(),

                  // const SizedBox(height: 30),

                  // // Connection Info Card
                  // _buildConnectionInfoCard(logic),

                  const SizedBox(height: 20),

                  // QR Code Card
                  _buildQRCodeCard(logic),

                  const SizedBox(height: 20),

                  // Files Summary Card
                  _buildFilesSummaryCard(logic),

                  const SizedBox(height: 20),

                  // Connected Device Indicator
                  _buildConnectedDeviceIndicator(),

                  const SizedBox(height: 20),

                  // Stop Button
                  _buildStopButton(context),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColor.colorWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColor.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Starting server...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Animated Rocket/Status Section
  Widget _buildAnimatedStatusSection() {
    return Obx(() {
      final isConnected = connManager.isConnected.value;
      final isTransferring = connManager.isTransferring.value;

      return Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [
                    AppColor.primary.withValues(alpha: 0.1),
                    AppColor.primary.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isConnected
                ? AppColor.primary.withValues(alpha: 0.3)
                : Colors.orange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background particles
            if (isTransferring) ..._buildParticles(),

            // Main Animation
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isTransferring)
                  _buildRocketAnimation()
                else if (isConnected)
                  _buildConnectedAnimation()
                else
                  _buildWaitingAnimation(),
                const SizedBox(height: 15),
                Text(
                  isTransferring
                      ? 'Transferring Files...'
                      : isConnected
                          ? 'Device Connected!'
                          : 'Waiting for Connection...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? AppColor.primary : Colors.orange,
                  ),
                ),
                if (isTransferring) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${connManager.currentFileIndex.value + 1}/${connManager.totalFiles.value} files',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  // Rocket Animation (Transferring)
  Widget _buildRocketAnimation() {
    return AnimatedBuilder(
      animation: _rocketAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _rocketAnimation.value),
          child: Transform.rotate(
            angle: -0.3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.colorWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Text(
                'ðŸš€',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
        );
      },
    );
  }

  // Connected Animation (Handshake)
  Widget _buildConnectedAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, Color(0xFF45B649)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Waiting Animation (Pulse)
  Widget _buildWaitingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.wifi_find,
              size: 80,
              color: Colors.orange,
            ),
          ),
        );
      },
    );
  }

  // Floating particles for transfer animation
  List<Widget> _buildParticles() {
    return List.generate(8, (index) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 1000 + (index * 100)),
        builder: (context, value, child) {
          return Positioned(
            left: 20 + (index * 40).toDouble(),
            top: 50 + (value * 100),
            child: Opacity(
              opacity: 1 - value,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // QR Code Card
  Widget _buildQRCodeCard(SendingProgressLogic logic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColor.colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ðŸ“±',
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(width: 10),
              Text(
                'Scan to Connect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.colorBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Receiver can scan this QR code for instant connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.colorWhite,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: QrImageView(
              data: logic.qrData.value,
              size: 200,
              backgroundColor: AppColor.colorWhite,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: AppColor.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: AppColor.colorBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Files Summary Card
  Widget _buildFilesSummaryCard(SendingProgressLogic logic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withValues(alpha: 0.1),
            AppColor.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Files Ready to Share',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.colorBlack,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Files',
                logic.filesToSend.length.toString(),
                Icons.file_copy_rounded,
              ),
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColor.primary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _buildStatItem(
                'Total Size',
                _formatBytes(
                  logic.filesToSend.fold(
                    0,
                    (sum, file) => sum + file.lengthSync(),
                  ),
                ),
                Icons.sd_storage_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColor.primary, Color(0xFF45B649)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Connected Device Indicator
  Widget _buildConnectedDeviceIndicator() {
    return Obx(() {
      if (!connManager.isConnected.value) {
        return const SizedBox.shrink();
      }

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF45B649)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Device Connected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          connManager.connectedDevice.value?.hostName ??
                              'Unknown Device',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // Stop Button
  Widget _buildStopButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (await _showExitConfirmation(context)) {
            Get.until((r) => r.isFirst);
            controller.stopServer();
          }
        },
        icon: const Icon(Icons.stop_circle_rounded, size: 24),
        label: const Text(
          'Stop Sharing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Colors.red.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    if (!connManager.isConnected.value) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text('Sure?'),
              ],
            ),
            content: const Text(
              'This will disconnect the connected device.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('NO'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
