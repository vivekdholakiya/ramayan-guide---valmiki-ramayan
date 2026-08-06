import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'hive_storage_service.dart';

/// LocalImageManager handles permanent image caching in the application
/// documents directory.
///
/// Features:
///  - Permanent storage in app_docs/cached_images/ (not temp directory)
///  - Downloads image URL once, saves to disk
///  - Loads from disk on app launch
///  - Auto-updates if image URL changes
///  - Graceful fallback on network failure
class LocalImageManager {
  final HiveStorageService _hiveStorage;
  Directory? _cachedImageDir;

  LocalImageManager(this._hiveStorage);

  Future<void> _ensureDirInitialized() async {
    if (_cachedImageDir != null) return;
    try {
      final appDocsDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDocsDir.path}/cached_images');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cachedImageDir = dir;
    } catch (e) {
      if (kDebugMode) print('[LocalImageManager] Directory init error: $e');
    }
  }

  /// Generates a unique, clean filename for a given remote image URL using SHA256.
  String _hashUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// Returns the local [File] if the image has already been downloaded and exists on disk.
  /// Otherwise returns null.
  Future<File?> getLocalFile(String url) async {
    if (url.trim().isEmpty) return null;
    await _ensureDirInitialized();

    final localPath = _hiveStorage.getLocalImagePath(url);
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists() && (await file.length()) > 0) {
        return file;
      }
    }

    // Check by URL hash in cached_images folder
    if (_cachedImageDir != null) {
      final hash = _hashUrl(url);
      final file = File('${_cachedImageDir!.path}/$hash.png');
      if (await file.exists() && (await file.length()) > 0) {
        await _hiveStorage.saveLocalImagePath(url, file.path);
        return file;
      }
    }

    return null;
  }

  /// Returns local image path if available. If missing, downloads it permanently
  /// to disk and returns the saved file path.
  Future<String?> getOrDownloadLocalPath(String url) async {
    if (url.trim().isEmpty) return null;

    // 1. Check local disk first
    final existingFile = await getLocalFile(url);
    if (existingFile != null) {
      return existingFile.path;
    }

    // 2. Download from remote URL
    return await downloadAndSaveImage(url);
  }

  /// Downloads the image from [url] and stores it permanently in app documents directory.
  Future<String?> downloadAndSaveImage(String url) async {
    if (url.trim().isEmpty) return null;
    await _ensureDirInitialized();
    if (_cachedImageDir == null) return null;

    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final hash = _hashUrl(url);
        final filePath = '${_cachedImageDir!.path}/$hash.png';
        final file = File(filePath);

        final bytes = await response.fold<List<int>>(
          <int>[],
          (buffer, data) => buffer..addAll(data),
        );

        if (bytes.isNotEmpty) {
          await file.writeAsBytes(bytes);
          await _hiveStorage.saveLocalImagePath(url, file.path);
          if (kDebugMode) {
            print('[LocalImageManager] Image cached permanently: $filePath');
          }
          return file.path;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LocalImageManager] Failed to download image ($url): $e');
      }
    }
    return null;
  }

  /// Batch download missing image URLs in background without blocking UI.
  Future<void> syncImageUrls(List<String> urls) async {
    for (final url in urls) {
      if (url.trim().isEmpty) continue;
      final file = await getLocalFile(url);
      if (file == null) {
        // Download missing image permanently
        await downloadAndSaveImage(url);
      }
    }
  }

  /// Remove old local cached image when remote image URL changes.
  Future<void> removeCachedImage(String url) async {
    try {
      final localPath = _hiveStorage.getLocalImagePath(url);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _hiveStorage.removeLocalImagePath(url);
      }
    } catch (e) {
      if (kDebugMode) print('[LocalImageManager] Cleanup error: $e');
    }
  }
}
