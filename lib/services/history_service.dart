// lib/services/history_service.dart
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class HistoryService {
  static const String _key = 'transferHistory';

  // StreamController for real-time updates
  static final StreamController<List<TransferHistory>>
      _historyStreamController =
      StreamController<List<TransferHistory>>.broadcast();

  // Expose stream for listeners
  static Stream<List<TransferHistory>> get historyStream =>
      _historyStreamController.stream;

  // Notify all listeners about history changes
  static Future<void> _notifyListeners() async {
    final histories = await getAllHistory();
    _historyStreamController.add(histories);
  }

  static Future<void> addHistory(TransferHistory history) async {
    final box = GetStorage();
    List<dynamic> histories = box.read(_key) ?? [];

    // Add to beginning of list (newest first)
    histories.insert(0, history.toJson());

    // Keep only last 100 transfers
    if (histories.length > 100) {
      histories = histories.take(100).toList();
    }

    await box.write(_key, histories);

    // 🔥 Notify all listeners about the change
    await _notifyListeners();
  }

  static Future<List<TransferHistory>> getAllHistory() async {
    final box = GetStorage();
    final List<dynamic> histories = box.read(_key) ?? [];

    // Convert to TransferHistory objects
    final List<TransferHistory> list = histories
        .map((h) => TransferHistory.fromJson(Map<String, dynamic>.from(h)))
        .toList();

    // ✅ Remove duplicates by unique combination of sender + fileName + isReceived
    final uniqueMap = <String, TransferHistory>{};

    for (var h in list) {
      final key = '${h.senderIP}_${h.senderName}_${h.fileName}_${h.isReceived}';
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = h;
      }
    }

    // Return list keeping the original (newest-first) order
    return uniqueMap.values.toList();
  }

  static Future<List<TransferHistory>> getReceivedHistory() async {
    final all = await getAllHistory();
    return all.where((h) => h.isReceived).toList();
  }

  static Future<List<TransferHistory>> getSentHistory() async {
    final all = await getAllHistory();
    return all.where((h) => !h.isReceived).toList();
  }

  static Future<void> deleteHistory(String id) async {
    final box = GetStorage();
    final List<Map<String, dynamic>> histories =
        (box.read(_key) as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    histories.removeWhere((h) => h['id'] == id);
    await box.write(_key, histories);

    // 🔥 Notify all listeners about the change
    await _notifyListeners();
  }

  static Future<void> clearAllHistory() async {
    final box = GetStorage();
    await box.remove(_key);

    // 🔥 Notify all listeners about the change
    await _notifyListeners();
  }

  // Dispose stream controller when app closes
  static void dispose() {
    _historyStreamController.close();
  }
}

class TransferHistory {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String senderName;
  final String senderIP;
  final DateTime timestamp;
  final bool isReceived;
  final bool isSuccess;

  TransferHistory({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.senderName,
    required this.senderIP,
    required this.timestamp,
    required this.isReceived,
    required this.isSuccess,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
        'senderName': senderName,
        'senderIP': senderIP,
        'timestamp': timestamp.toIso8601String(),
        'isReceived': isReceived,
        'isSuccess': isSuccess,
      };

  factory TransferHistory.fromJson(Map<String, dynamic> json) {
    return TransferHistory(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      senderName: json['senderName'],
      senderIP: json['senderIP'],
      timestamp: DateTime.parse(json['timestamp']),
      isReceived: json['isReceived'],
      isSuccess: json['isSuccess'],
    );
  }

  String get sizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get timeFormatted {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }

  String get fileType {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return 'Image';
    if (['mp4', 'avi', 'mkv', 'mov'].contains(ext)) return 'Video';
    if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) return 'Audio';
    if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) return 'Document';
    return 'File';
  }
}
