import 'package:client_f/pages/chat_page.dart';
import 'package:flutter/material.dart';

class SceneCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const SceneCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return ChatPage(sceneName: title);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
