import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageSelector {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromGallery() async {
    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // will custom compress
    );

    if (xFile == null) {
      return null;
    }

    return File(xFile.path);
  }
}
