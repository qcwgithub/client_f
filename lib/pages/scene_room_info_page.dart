import 'package:flutter/material.dart';
import 'package:scene_hub/gen/scene_room_info.dart';

class SceneRoomInfoPage extends StatelessWidget {
  final SceneRoomInfo sceneRoomInfo;
  const SceneRoomInfoPage({super.key, required this.sceneRoomInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scene Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scene ID: ${sceneRoomInfo.roomId}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Divider(),

            Text(
              "Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Expanded(child: child)
          ],
        ),
      ),
    );
  }
}
