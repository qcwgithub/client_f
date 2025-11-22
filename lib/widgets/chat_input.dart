import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final controller = TextEditingController();
  final void Function(String msg) callback;
  ChatInput({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
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

              callback(text);
              controller.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}