import 'package:flutter/material.dart';
import 'package:scene_hub/gen/scene_info.dart';

class SceneInfoPage extends StatelessWidget {
  final SceneInfo sceneInfo;
  const SceneInfoPage({super.key, required this.sceneInfo});

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
              "Scene ID: ${sceneInfo.roomId}",
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
