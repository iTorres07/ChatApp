import 'dart:io';

import 'package:chat_app_1/features/storage/data/firebase_data_source/cloud_storage_firebase_data_source.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageFirebaseDataSourceImpl
    implements CloudStorageFirebaseDataSource {
  final FirebaseStorage storage;

  CloudStorageFirebaseDataSourceImpl({required this.storage});

  @override
  Future<String> uploadGroupImage({required File file}) async {
    final ref = storage.ref().child(
          "group/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final imageUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return imageUrl;
  }

  @override
  Future<String> uploadProfileImage({required File file}) async {
    final ref = storage.ref().child(
          "profile/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final imageUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return imageUrl;
  }

  static String getNameOnly(String path) {
    return path.split('/').last.split('%').last.split("?").first;
  }

  @override
  Future<String> uploadImage({required File file}) async {
    final ref = storage.ref().child(
          "files/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final imageUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return imageUrl;
  }

  @override
  Future<String> uploadVideo({required File file}) async {
    final ref = storage.ref().child(
          "files/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final videoUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return videoUrl;
  }

  @override
  Future<String> uploadAudio({required File file}) async {
    final ref = storage.ref().child(
          "files/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final audioUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return audioUrl;
  }

  @override
  Future<String> uploadGif({required File file}) async {
    final ref = storage.ref().child(
          "files/${DateTime.now().millisecondsSinceEpoch}${getNameOnly(file.path)}",
        );

    final uploadTask = ref.putFile(file);

    final gifUrl = (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return gifUrl;
  }
}
