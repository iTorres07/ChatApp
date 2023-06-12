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

  @override
  Future<String> uploadImage({required File file}) async =>
      remoteDataSource.uploadImage(file: file);

  @override
  Future<String> uploadVideo({required File file}) async =>
      remoteDataSource.uploadVideo(file: file);

  @override
  Future<String> uploadAudio({required File file}) async =>
      remoteDataSource.uploadAudio(file: file);
}
