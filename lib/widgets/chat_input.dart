import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatelessWidget {
  final controller = TextEditingController();
  final void Function(String type, String text) callback;
  ChatInput({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              String? imageUrl = await _pickAndUploadImage();
              if (imageUrl != null) {
                callback("image", imageUrl);
              }
            },
            icon: const Icon(Icons.photo),
          ),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: () {
              String text = controller.text.trim();
              if (text.isEmpty) {
                return;
              }

              callback("text", text);
              controller.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) {
      return null;
    }

    // todo
    // FlutterImageCompress.compressWithFile(file.path,)

    String imageUrl = await _uploadFile(file);
    return imageUrl;
  }

  Future<String> _uploadFile(XFile file) async {
    await Future.delayed(Duration(seconds: 1));
    return "https://img2.baidu.com/it/u=1593073498,3942986965&fm=253&app=138&f=JPEG?w=699&h=1181";
  }
}
