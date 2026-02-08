import 'package:flutter/material.dart';
import 'package:scene_hub/gen/room_info.dart';

class RoomInfoPage extends StatelessWidget {
  final int roomId;
  const RoomInfoPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room ID: $roomId", style: TextStyle(fontSize: 16)),
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
