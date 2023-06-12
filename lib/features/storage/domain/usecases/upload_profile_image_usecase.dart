import 'dart:io';

import 'package:chat_app_1/features/storage/domain/repository/cloud_storage_repository.dart';

class UploadProfileImageUseCase {
  final CloudStorageRepository repository;

  UploadProfileImageUseCase({required this.repository});

  Future<String> call({required File file}) async {
    return repository.uploadProfileImage(file: file);
  }
}
