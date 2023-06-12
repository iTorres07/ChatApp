import 'dart:io';

import 'package:chat_app_1/features/storage/domain/repository/cloud_storage_repository.dart';

class UploadVideoUseCase {
  final CloudStorageRepository repository;

  UploadVideoUseCase({required this.repository});

  Future<String> call({required File file}) async {
    return await repository.uploadVideo(file: file);
  }
}
