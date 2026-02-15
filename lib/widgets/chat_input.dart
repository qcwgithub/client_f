import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/sc.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller; // 新增可选参数
  final void Function(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  )
  callback;
  const ChatInput({
    super.key,
    required this.controller,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              ChatMessageImageContent? imageContent =
                  await _pickAndUploadImage();
              if (imageContent != null) {
                callback(ChatMessageType.image, "", imageContent);
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

              callback(ChatMessageType.text, text, null);
              controller.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<ChatMessageImageContent?> _pickAndUploadImage() async {
    final File? file = await sc.imageSelector.pickFromGallery();
    if (file == null) {
      return null;
    }

    ChatMessageImageContent? imageContent = await sc.imageUploader.uploadImage(
      file,
    );

    return imageContent;
  }
}
