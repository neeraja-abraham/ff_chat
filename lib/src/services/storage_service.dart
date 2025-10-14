import 'package:ff_chat/src/services/media_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum MediaUploadType { image, video, file }

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask? uploadTask;

  Future<String?> uploadFileToChat({
    required PickedMedia media,
    required String chatId,
    required MediaUploadType typeFolder,
  }) async {
    Reference fileRef = _storage
        .ref("chats/$chatId/$typeFolder")
        .child(
          '${DateTime.now().toIso8601String()}${p.extension(media.file?.path ?? '')}',
        );

    if (kIsWeb) {
      uploadTask = fileRef.putData(media.bytes!);
    } else if (media.file != null) {
      uploadTask = fileRef.putFile(media.file!);
    } else {}

    return uploadTask?.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
