import 'dart:io';

import 'package:chat_app_1/features/storage/data/firebase_data_source/cloud_storage_firebase_data_source.dart';
import 'package:chat_app_1/features/storage/domain/repository/cloud_storage_repository.dart';

class CloudStorageRepositoryImpl implements CloudStorageRepository {
  final CloudStorageFirebaseDataSource remoteDataSource;

  CloudStorageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadGroupImage({required File file}) async =>
      remoteDataSource.uploadGroupImage(file: file);

  @override
  Future<String> uploadProfileImage({required File file}) async =>
      remoteDataSource.uploadProfileImage(file: file);
}
