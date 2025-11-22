import 'package:flutter/material.dart';

class ChatMessageItem extends StatelessWidget {
  final String message;
  const ChatMessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message),
        ),
      ),
    );
  }
}
