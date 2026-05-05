// lib/models/file_models.dart
import 'dart:io';

import 'package:zero_share/generated/assets.dart';

class FileModel {
  final String name;
  final String path;
  final int size;
  final String extension;
  final File file;

  FileModel({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.file,
  });

  factory FileModel.fromFile(File file) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final extension =
        fileName.contains('.') ? fileName.split('.').last : 'unknown';
    final size = file.lengthSync();

    return FileModel(
      name: fileName,
      path: file.path,
      size: size,
      extension: extension,
      file: file,
    );
  }

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}

// Transfer Message Model (like chat messages)
// lib/models/files_model.dart
class TransferMessage {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String senderName;
  final String senderIP;
  final bool isSentByMe;
  final DateTime timestamp;
  TransferStatus status;
  double progress; // ✅ NEW: Progress percentage (0.0 to 1.0)

  TransferMessage({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.senderName,
    required this.senderIP,
    required this.isSentByMe,
    required this.timestamp,
    required this.status,
    this.progress = 0.0, // ✅ Default 0%
  });

  // ✅ Add copyWith for updating progress
  TransferMessage copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? senderName,
    String? senderIP,
    bool? isSentByMe,
    DateTime? timestamp,
    TransferStatus? status,
    double? progress,
  }) {
    return TransferMessage(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      senderName: senderName ?? this.senderName,
      senderIP: senderIP ?? this.senderIP,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'senderName': senderName,
      'senderIP': senderIP,
      'isSentByMe': isSentByMe,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'progress': progress,
    };
  }
}

enum TransferStatus {
  waiting,
  sending,
  receiving,
  completed,
  failed,
  cancelled,
}

// Room Session Model
class RoomSession {
  final String roomId;
  final String hostName;
  final String hostIP;
  final int port;
  final String? guestName;
  final String? guestIP;
  final DateTime createdAt;
  final bool isHost;

  RoomSession({
    required this.roomId,
    required this.hostName,
    required this.hostIP,
    required this.port,
    this.guestName,
    this.guestIP,
    required this.createdAt,
    required this.isHost,
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'hostName': hostName,
        'hostIP': hostIP,
        'port': port,
        'guestName': guestName,
        'guestIP': guestIP,
        'createdAt': createdAt.toIso8601String(),
        'isHost': isHost,
      };

  factory RoomSession.fromJson(Map<String, dynamic> json) {
    return RoomSession(
      roomId: json['roomId'],
      hostName: json['hostName'],
      hostIP: json['hostIP'],
      port: json['port'],
      guestName: json['guestName'],
      guestIP: json['guestIP'],
      createdAt: DateTime.parse(json['createdAt']),
      isHost: json['isHost'],
    );
  }
}

// Keep existing models
class SenderModel {
  final String hostName;
  final String ip;
  final int port;
  final String os;
  final String avatar;
  final int fileCount;

  SenderModel({
    required this.hostName,
    required this.ip,
    required this.port,
    required this.os,
    required this.avatar,
    this.fileCount = 0,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      hostName: json['hostName'] ?? json['host'] ?? 'mashwani',
      ip: json['ip'] ?? '',
      port: json['port'] ?? 4040,
      os: json['os'] ?? 'unknown',
      avatar: json['avatar'] ?? Assets.imagesImgAvatarFemaleBlue,
      fileCount: json['fileCount'] ?? json['files-count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hostName': hostName,
        'ip': ip,
        'port': port,
        'os': os,
        'avatar': avatar,
        'fileCount': fileCount,
      };
}

enum FileStatus { waiting, downloading, downloaded, cancelled, error }
