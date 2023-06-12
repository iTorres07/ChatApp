import 'dart:io';

import 'package:chat_app_1/features/storage/domain/repository/cloud_storage_repository.dart';

class UploadImageUseCase {
  final CloudStorageRepository repository;

  UploadImageUseCase({required this.repository});

  Future<String> call({required File file}) async {
    print("a");
    return await repository.uploadImage(file: file);
  }
}
