import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:flutter/material.dart';

class SceneCard extends StatelessWidget {
  final RoomInfo roomInfo;

  const SceneCard({super.key, required this.roomInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(roomInfo.title),
            subtitle: Text(
              roomInfo.desc,
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return ChatPage(roomInfo: roomInfo);
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
