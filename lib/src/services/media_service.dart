import 'dart:typed_data';
import 'dart:io' show File; // Only works on mobile

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

class PickedMedia {
  final String name;
  final File? file; // For mobile
  final Uint8List? bytes; // For web

  PickedMedia({required this.name, this.file, this.bytes});
}

class MediaService {
  // Pick Image
  Future<PickedMedia?> pickImage() async {
    if (kIsWeb) {
      final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        return PickedMedia(name: xFile.name, bytes: bytes);
      }
    } else {
      final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        return PickedMedia(name: xFile.name, file: File(xFile.path));
      }
    }
    return null;
  }

  // Pick Video
  Future<PickedMedia?> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      if (kIsWeb) {
        final bytes = await video.readAsBytes();
        return PickedMedia(name: video.name, bytes: bytes);
      } else {
        return PickedMedia(name: video.name, file: File(video.path));
      }
    }
    return null;
  }

  // Pick File (any type)
  Future<PickedMedia?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'csv',
        'zip',
        'rar',
        'ppt',
        'pptx',
      ],
    );
    debugPrint('RESULT:::$result');
    if (result != null) {
      final file = result.files.single;
      if (kIsWeb) {
        return PickedMedia(name: file.name, bytes: file.bytes);
      } else if (file.path != null) {
        return PickedMedia(name: file.name, file: File(file.path!));
      }
    }
    return null;
  }
}
