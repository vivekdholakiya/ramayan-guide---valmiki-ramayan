import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../data/repositories/ramayan_repository.dart';
import '../services/hive_storage_service.dart';
import '../services/local_image_manager.dart';

// ── Core Service & Storage Providers ─────────────────────────────────────

/// Must be overridden in main.dart via ProviderScope overrides
final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  throw UnimplementedError(
      'hiveStorageServiceProvider must be overridden in ProviderScope');
});

final localImageManagerProvider = Provider<LocalImageManager>((ref) {
  final hiveStorage = ref.watch(hiveStorageServiceProvider);
  return LocalImageManager(hiveStorage);
});

// ── Data Source Providers ──────────────────────────────────────────────────

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  final hiveStorage = ref.watch(hiveStorageServiceProvider);
  final imageManager = ref.watch(localImageManagerProvider);
  return LocalDataSource(
    hiveStorage: hiveStorage,
    imageManager: imageManager,
  );
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource();
});

// ── Repository Provider ───────────────────────────────────────────────────

final ramayanRepositoryProvider = Provider<RamayanRepository>((ref) {
  final localDS = ref.watch(localDataSourceProvider);
  final remoteDS = ref.watch(remoteDataSourceProvider);
  return RamayanRepository(
    localDataSource: localDS,
    remoteDataSource: remoteDS,
  );
});

// ── Local Image File Family Provider ──────────────────────────────────────

/// Resolves a remote image URL to a local cached [File] asynchronously.
/// Returns null if image is not yet cached locally.
final localImageFileProvider =
    FutureProvider.family<File?, String>((ref, url) async {
  if (url.trim().isEmpty) return null;
  final repository = ref.watch(ramayanRepositoryProvider);
  return await repository.getLocalImageFile(url);
});
