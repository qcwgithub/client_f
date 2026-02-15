import 'dart:io';
import 'dart:typed_data';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:image/image.dart';

class ImageUploader {
  Future<ChatMessageImageContent> uploadImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final Image? image = decodeImage(bytes);
    if (image == null) {
      throw Exception("decodeImage failed");
    }

    final Image resized = _resizeIfNeeded(image, maxSide: 1920);

    final Uint8List compressed = Uint8List.fromList(
      encodeJpg(resized, quality: 80),
    );

    final String imageUrl = await _uploadToOss(compressed);
    return ChatMessageImageContent(
      url: imageUrl,
      width: resized.width,
      height: resized.height,
      size: compressed.length,
    );
  }

  Image _resizeIfNeeded(Image image, {required int maxSide}) {
    final int w = image.width;
    final int h = image.height;

    if (w <= maxSide && h <= maxSide) {
      return image;
    }

    int newHeight;
    int newWidth;

    if (w > h) {
      newWidth = maxSide;
      newHeight = (h * maxSide / w).round();
    } else {
      newHeight = maxSide;
      newWidth = (w * maxSide / h).round();
    }

    return copyResize(image, width: newWidth, height: newHeight);
  }

  Future<String> _uploadToOss(Uint8List data) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // 临时地址（假装OSS返回）
    return "https://cdn-temp.example.com/${DateTime.now().millisecondsSinceEpoch}.jpg";
  }
}
