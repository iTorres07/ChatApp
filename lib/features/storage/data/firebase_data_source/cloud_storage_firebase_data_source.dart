import 'dart:io';

abstract class CloudStorageFirebaseDataSource {
  Future<String> uploadProfileImage({required File file});
  Future<String> uploadGroupImage({required File file});
}
