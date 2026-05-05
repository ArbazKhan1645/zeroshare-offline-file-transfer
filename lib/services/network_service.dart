// lib/services/network_service.dart
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';

class NetworkService {
  static Future<List<String>> getLocalIPs() async {
    final List<String> ips = [];

    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            if (!addr.address.startsWith('127.')) {
              ips.add(addr.address);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting IPs: $e');
    }

    return ips;
  }

  static List<String> getNetworkPrefixes(List<String> ips) {
    final List<String> prefixes = [];

    for (String ip in ips) {
      final List<String> parts = ip.split('.');
      if (parts.length == 4) {
        parts.removeLast();
        prefixes.add(parts.join('.'));
      }
    }

    return prefixes;
  }

  static Future<List<String>> scanNetwork({
    int port = 4040,
    int startRange = 1,
    int endRange = 255,
  }) async {
    final List<String> activeHosts = [];
    final List<String> localIPs = await getLocalIPs();

    if (localIPs.isEmpty) {
      return activeHosts;
    }

    final List<String> networkPrefixes = getNetworkPrefixes(localIPs);
    final List<Future<Map<String, dynamic>>> scanTasks = [];

    for (String prefix in networkPrefixes) {
      for (int i = startRange; i <= endRange; i++) {
        final String host = '$prefix.$i';

        if (localIPs.contains(host)) continue;

        scanTasks.add(_scanHost(host, port));
      }
    }

    final List<Map<String, dynamic>> results = await Future.wait(scanTasks);

    for (var result in results) {
      if (result['success'] == true) {
        activeHosts.add(result['host']);
      }
    }

    return activeHosts;
  }

  static Future<Map<String, dynamic>> _scanHost(String host, int port) async {
    try {
      final Socket socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: 1500),
      );
      socket.destroy();
      return {'success': true, 'host': host};
    } catch (e) {
      return {'success': false, 'host': host};
    }
  }

  static Future<String?> getPreferredIP() async {
    final List<String> ips = await getLocalIPs();

    if (ips.isEmpty) return null;

    for (String ip in ips) {
      if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
        return ip;
      }
    }

    return ips.first;
  }
}
