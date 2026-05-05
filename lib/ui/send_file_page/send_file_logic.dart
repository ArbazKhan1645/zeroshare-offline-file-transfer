import 'package:media_store_plus/media_store_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

enum DocumentType { all, pdf, excel, ppt, txt, doc, other }

class SendFileLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  var allDocumentFiles = <File>[].obs;

  Future<void> loadAllDocuments() async {
    try {
      isLoadingDocuments.value = true;

      List<File> allFiles = [];

      try {
        // Get all storage directories
        final List<Directory> searchDirectories =
            await _getAllSearchableDirectories();

        for (Directory directory in searchDirectories) {
          try {
            if (await directory.exists()) {
              await _scanDirectory(directory, allFiles);
            }
          } catch (e) {
            debugPrint('Error scanning directory ${directory.path}: $e');
          }
        }
      } catch (e) {
        debugPrint('Error getting searchable directories: $e');
      }

      try {
        // Remove duplicates by file name + extension (case-insensitive)
        final uniqueFiles = <String, File>{};
        for (var file in allFiles) {
          try {
            final name = file.path.split('/').last.toLowerCase();
            final ext = name.split('.').length > 1 ? name.split('.').last : '';
            final key = '$name|$ext';
            uniqueFiles[key] = file;
          } catch (e) {
            debugPrint('Error processing file for uniqueness: $e');
          }
        }

        // Convert map values back to list
        allFiles = uniqueFiles.values.toList();
      } catch (e) {
        debugPrint('Error removing duplicates: $e');
      }

      try {
        // Sort alphabetically by name
        allFiles.sort(
          (a, b) => a.path
              .split('/')
              .last
              .toLowerCase()
              .compareTo(b.path.split('/').last.toLowerCase()),
        );
      } catch (e) {
        debugPrint('Error sorting files: $e');
      }

      allDocumentFiles.value = allFiles;
      filteredFiles.value = allFiles;

      debugPrint('Total unique files found: ${allFiles.length}');

      update();
    } catch (e) {
      debugPrint('Critical error loading documents: $e');

      Get.snackbar('Error', 'Failed to load documents: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<List<Directory>> _getAllSearchableDirectories() async {
    final List<Directory> directories = [];

    try {
      if (Platform.isAndroid) {
        // Main storage paths
        directories.addAll([
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/Downloads'),
          Directory('/storage/emulated/0/Documents'),
          Directory('/storage/emulated/0/DCIM'),
          Directory('/storage/emulated/0/Pictures'),
          Directory('/storage/emulated/0/Music'),
          Directory('/storage/emulated/0/Movies'),
          Directory('/storage/emulated/0/Recordings'),
          Directory('/storage/emulated/0/Audiobooks'),
          Directory('/storage/emulated/0/Podcasts'),
          Directory('/storage/emulated/0/Alarms'),
          Directory('/storage/emulated/0/Notifications'),
          Directory('/storage/emulated/0/Ringtones'),
          Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Documents'),
          Directory(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents',
          ),
          Directory(
            '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/WhatsApp Business Documents',
          ),
          Directory('/storage/emulated/0/Telegram/Telegram Documents'),
          Directory(
            '/storage/emulated/0/Android/data/org.telegram.messenger/files/Telegram/Telegram Documents',
          ),
          Directory('/storage/emulated/0/Android/media'),
          Directory('/storage/emulated/0/bluetooth'),
          Directory('/storage/emulated/0/Bluetooth'),
        ]);

        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            directories.add(externalDir);
          }
        } catch (e) {
          debugPrint('Error getting external storage directory: $e');
        }

        try {
          final List<Directory>? externalDirs =
              await getExternalStorageDirectories();
          if (externalDirs != null) {
            directories.addAll(externalDirs);
          }
        } catch (e) {
          debugPrint('Error getting external storage directories: $e');
        }
      }

      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        directories.add(appDocDir);
      } catch (e) {
        debugPrint('Error getting app documents directory: $e');
      }
    } catch (e) {
      debugPrint('Critical error getting directories: $e');
    }

    return directories;
  }

  void clearSelections() {
    try {
      selectedDocumentFiles.clear();
      debugPrint('Selections cleared');
    } catch (e) {
      debugPrint('Error clearing selections: $e');
    }
  }

  Future<void> refreshDocuments() async {
    try {
      await loadAllDocuments();
      debugPrint('Documents refreshed');
    } catch (e) {
      debugPrint('Error refreshing documents: $e');
    }
  }

  Future<void> _scanDirectory(Directory directory, List<File> fileList) async {
    try {
      final dirName = directory.path.split('/').last;
      if (dirName.startsWith('.') ||
          dirName == 'Android' ||
          dirName == 'data' ||
          dirName == 'obb') {
        return;
      }

      await for (FileSystemEntity entity in directory.list(
        followLinks: false,
      )) {
        try {
          if (entity is File) {
            if (_isDocumentFile(entity.path)) {
              fileList.add(entity);
            }
          } else if (entity is Directory) {
            await _scanDirectory(entity, fileList);
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Cannot access: ${directory.path}');
    }
  }

  bool _isDocumentFile(String path) {
    try {
      final lowercasePath = path.toLowerCase();
      final documentExtensions = [
        '.pdf',
        '.xlsx',
        '.xls',
        '.xlsm',
        '.xlsb',
        '.xltx',
        '.xltm',
        '.csv',
        '.ppt',
        '.pptx',
        '.pptm',
        '.potx',
        '.potm',
        '.ppsx',
        '.ppsm',
        '.doc',
        '.docx',
        '.docm',
        '.dotx',
        '.dotm',
        '.txt',
        '.rtf',
        '.log',
        '.odt',
        '.ods',
        '.odp',
        '.pages',
        '.numbers',
        '.key',
        '.zip',
        '.rar',
        '.7z',
        '.tar',
        '.gz',
        '.apk',
      ];
      return documentExtensions.any((ext) => lowercasePath.endsWith(ext));
    } catch (e) {
      debugPrint('Error checking document file: $e');

      return false;
    }
  }

  final RxSet<File> selectedDocumentFiles = <File>{}.obs;
  final RxList<File> allFiles = <File>[].obs;
  final RxList<File> filteredFiles = <File>[].obs;
  final Rx<DocumentType> selectedType = DocumentType.all.obs;
  final RxBool isLoadingDocuments = false.obs;

  final RxMap<String, List<AssetEntity>> folderPhotos =
      RxMap<String, List<AssetEntity>>();
  final RxMap<String, List<AssetEntity>> folderVideos =
      RxMap<String, List<AssetEntity>>();
  final RxMap<String, List<AssetEntity>> musicFiles =
      RxMap<String, List<AssetEntity>>();

  final RxSet<AssetEntity> selectedFiles = <AssetEntity>{}.obs;

  final RxMap<String, int> currentPhotoPages = RxMap<String, int>();
  final RxMap<String, int> currentVideoPages = RxMap<String, int>();

  final Rx<int?> selectedFolderIndex = Rx<int?>(null);

  late TabController tabController;
  final mediaStorePlugin = MediaStore();
  int? argIndex;

  static const int pageSize = 50;

  int get selectedDocumentFileCount => selectedDocumentFiles.length;
  int get selectedFileCount => selectedFiles.length;
  int get totalSelectedFileCount =>
      selectedFileCount + selectedDocumentFileCount;

  void toggleDocumentFileSelection(File file) {
    try {
      if (selectedDocumentFiles.contains(file)) {
        selectedDocumentFiles.remove(file);
      } else {
        selectedDocumentFiles.add(file);
      }
    } catch (e) {
      debugPrint('Error toggling document file selection: $e');
    }
  }

  void clearDocumentFileSelections() {
    try {
      selectedDocumentFiles.clear();
    } catch (e) {
      debugPrint('Error clearing document file selections: $e');
    }
  }

  void selectAllFilteredDocuments() {
    try {
      selectedDocumentFiles.addAll(filteredFiles);
    } catch (e) {
      debugPrint('Error selecting all filtered documents: $e');
    }
  }

  void toggleFileSelection(AssetEntity file) {
    try {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file);
      } else {
        selectedFiles.add(file);
      }
    } catch (e) {
      debugPrint('Error toggling file selection: $e');
    }
  }

  void clearAllSelections() {
    try {
      selectedFiles.clear();
      selectedDocumentFiles.clear();
    } catch (e) {
      debugPrint('Error clearing all selections: $e');
    }
  }

  void onFolderTap(int index) {
    try {
      selectedFolderIndex.value = selectedFolderIndex.value == index
          ? null
          : index;
    } catch (e) {
      debugPrint('Error toggling folder: $e');
    }
  }

  Future<List<File>> getAllSelectedFiles() async {
    final List<File> files = [];

    try {
      for (var asset in selectedFiles) {
        try {
          final file = await asset.file;
          if (file != null) {
            debugPrint('Selected asset file: ${file.path}');
            files.add(file);
          }
        } catch (e) {
          debugPrint('Error getting file from asset: $e');
        }
      }

      files.addAll(selectedDocumentFiles);
      debugPrint('Total selected files: ${files.length}');
    } catch (e) {
      debugPrint('Critical error getting all selected files: $e');
    }

    return files;
  }

  void filterDocuments(DocumentType type) {
    try {
      if (isLoadingDocuments.value) {
        return;
      }
      selectedType.value = type;

      if (type == DocumentType.all) {
        filteredFiles.value = allDocumentFiles;
        return;
      }

      filteredFiles.value = allDocumentFiles.where((file) {
        try {
          final path = file.path.toLowerCase();

          switch (type) {
            case DocumentType.pdf:
              return path.endsWith('.pdf');
            case DocumentType.excel:
              return path.endsWith('.xlsx') ||
                  path.endsWith('.xls') ||
                  path.endsWith('.xlsm') ||
                  path.endsWith('.csv');
            case DocumentType.ppt:
              return path.endsWith('.ppt') ||
                  path.endsWith('.pptx') ||
                  path.endsWith('.pptm') ||
                  path.endsWith('.ppsx');
            case DocumentType.txt:
              return path.endsWith('.txt') ||
                  path.endsWith('.rtf') ||
                  path.endsWith('.log');
            case DocumentType.doc:
              return path.endsWith('.doc') ||
                  path.endsWith('.docx') ||
                  path.endsWith('.docm');
            case DocumentType.other:
              return !path.endsWith('.pdf') &&
                  !path.endsWith('.xlsx') &&
                  !path.endsWith('.xls') &&
                  !path.endsWith('.ppt') &&
                  !path.endsWith('.pptx') &&
                  !path.endsWith('.txt') &&
                  !path.endsWith('.doc') &&
                  !path.endsWith('.docx');
            default:
              return true;
          }
        } catch (e) {
          debugPrint('Error filtering file: $e');
          return false;
        }
      }).toList();

      debugPrint('Filtered ${filteredFiles.length} files for $type');
    } catch (e) {
      debugPrint('Error in filterDocuments: $e');
    }
  }

  String getFileType(File file) {
    try {
      final ext = file.path.toLowerCase();
      if (ext.endsWith('.pdf')) return 'PDF';
      if (ext.endsWith('.xlsx') || ext.endsWith('.xls')) return 'Excel';
      if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return 'PowerPoint';
      if (ext.endsWith('.txt')) return 'Text';
      if (ext.endsWith('.doc') || ext.endsWith('.docx')) return 'Word';
      if (ext.endsWith('.zip')) return 'ZIP';
      if (ext.endsWith('.rar')) return 'RAR';
      if (ext.endsWith('.iso')) return 'ISO';
      return 'Document';
    } catch (e) {
      debugPrint('Error getting file type: $e');

      return 'Document';
    }
  }

  String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } catch (e) {
      debugPrint('Error getting file size: $e');

      return 'Unknown';
    }
  }

  String getSelectedFilesInfo() {
    try {
      final total = totalSelectedFileCount;
      if (total == 0) return 'No files selected';
      if (total == 1) return '1 file selected';
      return '$total files selected';
    } catch (e) {
      debugPrint('Error getting selected files info: $e');

      return 'Error';
    }
  }

  final RxBool hasStoragePermission = true.obs;

  Future<void> baseDirectory() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo androidDeviceInfo =
          await deviceInfoPlugin.androidInfo;

      isLoadingDocuments.value = true;

      if (androidDeviceInfo.version.sdkInt < 30) {
        final PermissionStatus permissionStatus = await Permission.storage
            .request();
        if (permissionStatus.isGranted) {
          hasStoragePermission.value = true;
          await loadAllDocuments();
        } else {
          hasStoragePermission.value = false;
          debugPrint('Storage permission denied');
        }
      } else {
        final PermissionStatus permissionStatus = await Permission
            .manageExternalStorage
            .request();
        if (permissionStatus.isGranted) {
          hasStoragePermission.value = true;
          await loadAllDocuments();
        } else {
          hasStoragePermission.value = false;
          debugPrint('Manage external storage permission denied');
        }
      }
    } catch (e) {
      debugPrint('Error in baseDirectory: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> getFiles(String directoryPath) async {
    try {
      final rootDirectory = Directory(directoryPath);

      if (!await rootDirectory.exists()) {
        debugPrint('Directory does not exist: $directoryPath');
        return;
      }

      await for (var entity in rootDirectory.list(recursive: true)) {
        try {
          if (entity is File) {
            if (_isRestrictedDirectory(entity.path)) continue;
            if (_isDocumentFile(entity.path)) {
              allFiles.add(entity);
            }
          }
        } catch (e) {
          debugPrint('Error processing file: $e');
        }
      }
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        debugPrint('Permission denied for directory: $directoryPath');
      } else {
        debugPrint('Error accessing directory $directoryPath: $e');
      }
    }
  }

  bool _isRestrictedDirectory(String path) {
    try {
      final restrictedPaths = [
        '/Android/data',
        '/Android/obb',
        '/.',
        '/cache',
        '/code_cache',
      ];
      return restrictedPaths.any((restricted) => path.contains(restricted));
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchMediaFiles() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        debugPrint('Photo permission not granted');
        return;
      }

      await _fetchAssets(
        RequestType.image,
        folderPhotos,
        currentPhotoPages,
        null,
      );
      await _fetchAssets(
        RequestType.video,
        folderVideos,
        currentVideoPages,
        null,
      );
    } catch (e) {
      debugPrint('Error fetching media files: $e');
    }
  }

  Future<void> _fetchAssets(
    RequestType type,
    RxMap<String, List<AssetEntity>> targetMap,
    RxMap<String, int> currentPages,
    String? folderName,
  ) async {
    try {
      final paths = await PhotoManager.getAssetPathList(type: type);

      for (final path in paths) {
        try {
          if (folderName != null && path.name != folderName) continue;

          final totalAssets = await path.assetCountAsync;
          final currentPage = currentPages[path.name] ?? 0;

          if ((targetMap[path.name]?.length ?? 0) >= totalAssets) {
            continue;
          }

          final newAssets = await path.getAssetListPaged(
            page: currentPage,
            size: pageSize,
          );

          if (newAssets.isNotEmpty) {
            targetMap[path.name] = [...?targetMap[path.name], ...newAssets];
          }

          currentPages[path.name] = currentPage + 1;
        } catch (e) {
          debugPrint('Error processing path ${path.name}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error fetching assets: $e');
    }
  }

  Future<void> fetchMoreAssets(String folderName, bool isImage) async {
    try {
      final targetMap = isImage ? folderPhotos : folderVideos;
      final currentPages = isImage ? currentPhotoPages : currentVideoPages;

      await _fetchAssets(
        isImage ? RequestType.image : RequestType.video,
        targetMap,
        currentPages,
        folderName,
      );
    } catch (e) {
      debugPrint('Error fetching more assets: $e');
    }
  }

  Future<void> fetchAudioFiles() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        debugPrint('Audio permission not granted');

        return;
      }

      musicFiles.clear();
      final Map<String, AssetEntity> absolutelyUniqueFiles = {};

      final List<AssetPathEntity> audioPaths =
          await PhotoManager.getAssetPathList(type: RequestType.audio);
      debugPrint('Found ${audioPaths.length} audio paths');

      for (var path in audioPaths) {
        try {
          debugPrint('Scanning path: ${path.name}');

          final int tAssets = await path.assetCountAsync;
          final List<AssetEntity> audioAssets = await path.getAssetListRange(
            start: 0,
            end: tAssets,
          );
          debugPrint('Assets in ${path.name}: ${audioAssets.length}');

          for (var asset in audioAssets) {
            try {
              final uniqueKey = asset.id;
              if (!absolutelyUniqueFiles.containsKey(uniqueKey)) {
                absolutelyUniqueFiles[uniqueKey] = asset;
              }
            } catch (e) {
              debugPrint('Error processing asset: $e');
            }
          }
        } catch (e) {
          debugPrint('Error processing path ${path.name}: $e');
        }
      }

      debugPrint(
        'Total unique files after deduplication: ${absolutelyUniqueFiles.length}',
      );

      for (var asset in absolutelyUniqueFiles.values) {
        try {
          final title = asset.title ?? 'Unknown';
          String firstLetter = title[0].toUpperCase();

          if (!RegExp(r'^[A-Z]$').hasMatch(firstLetter)) {
            firstLetter = '#';
          }

          if (!musicFiles.containsKey(firstLetter)) {
            musicFiles[firstLetter] = [];
          }

          musicFiles[firstLetter]!.add(asset);
        } catch (e) {
          debugPrint('Error grouping file: $e');
        }
      }

      musicFiles.forEach((key, songs) {
        try {
          songs.sort((a, b) {
            final nameA = (a.title ?? '').toLowerCase();
            final nameB = (b.title ?? '').toLowerCase();
            return nameA.compareTo(nameB);
          });
        } catch (e) {
          debugPrint('Error sorting group $key: $e');
        }
      });

      int totalInGroups = 0;
      musicFiles.forEach((key, songs) {
        debugPrint('Group $key: ${songs.length} files');
        totalInGroups += songs.length;
      });

      debugPrint('Total files in groups: $totalInGroups');
    } catch (e) {
      debugPrint('Critical error fetching audio files: $e');
    }
  }

  void changeTab(int index) {
    try {
      tabController.index = index;
    } catch (e) {
      debugPrint('Error changing tab: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (!Platform.isAndroid) return false;

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final int sdkInt = androidInfo.version.sdkInt;

      final List<Permission> permissionsToRequest = [];

      if (sdkInt >= 33) {
        permissionsToRequest.addAll([
          Permission.audio,
          Permission.location,
          Permission.nearbyWifiDevices,
          Permission.videos,
          Permission.photos,
        ]);
      } else if (sdkInt >= 29) {
        permissionsToRequest.addAll([Permission.storage]);
      } else {
        permissionsToRequest.add(Permission.storage);
      }

      final Map<Permission, PermissionStatus> statuses =
          await permissionsToRequest.request();

      for (var permission in permissionsToRequest) {
        if (statuses[permission]?.isDenied ?? false) {
          debugPrint('Required permissions denied: ${permission.toString()}');

          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');

      return false;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      argIndex = args?['tabIndex'];
      // Initialize the TabController
      tabController = TabController(length: 4, vsync: this);

      // MediaStore initialization
      if (Platform.isAndroid) {
        try {
          await MediaStore.ensureInitialized();
        } catch (e) {
          debugPrint('MediaStore initialization error: $e');
        }
      }

      // Request permissions
      final List<Permission> permissions = [Permission.storage];
      final mediaStore = MediaStore();

      try {
        if ((await mediaStore.getPlatformSDKInt()) >= 33) {
          permissions.addAll([
            Permission.photos,
            Permission.audio,
            Permission.videos,
          ]);
        }
      } catch (e) {
        debugPrint('Error getting SDK int: $e');
      }

      try {
        await permissions.request();
        MediaStore.appFolder = 'ZeroShare';
      } catch (e) {
        debugPrint('Error requesting permissions: $e');
      }

      debugPrint('Received tabIndex: $argIndex');

      if (argIndex != null) {
        try {
          tabController.index = argIndex!;
          debugPrint('Setting tab index to: $argIndex');
          changeTab(argIndex!);
          if (argIndex == 2) {
            await fetchAudioFiles();
          }
        } catch (e) {
          debugPrint('Error setting initial tab: $e');
        }
      }

      // Fetch all data
      try {
        await Future.wait([
          fetchMediaFiles(),
          fetchAudioFiles(),
          baseDirectory(),
        ]);
      } catch (e) {
        debugPrint('Error fetching initial data: $e');
      }
    } catch (e) {
      debugPrint('Critical error in SendFileLogic onInit: $e');
    }
  }

  void manualupdatearg(int? argindex) {
    try {
      if (argindex != null) {
        tabController.index = argindex;
        debugPrint('Setting tab index to: $argindex');
        changeTab(argindex);
      }
    } catch (e) {
      debugPrint('Error in manualupdatearg: $e');
    }
  }

  @override
  void onClose() {
    try {
      tabController.dispose();
      super.onClose();
      debugPrint('SendFileLogic closed');
    } catch (e) {
      debugPrint('Error in SendFileLogic onClose: $e');

      try {
        super.onClose();
      } catch (superError) {
        debugPrint('Error calling super.onClose: $superError');
      }
    }
  }
}
