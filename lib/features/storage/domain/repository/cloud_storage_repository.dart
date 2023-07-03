import 'dart:io';

abstract class CloudStorageRepository {
  Future<String> uploadProfileImage({required File file});
  Future<String> uploadGroupImage({required File file});
  Future<String> uploadImage({required File file});
  Future<String> uploadVideo({required File file});
  Future<String> uploadAudio({required File file});
  Future<String> uploadPdf({required File file});
}
