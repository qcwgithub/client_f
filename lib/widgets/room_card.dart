import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:scene_hub/providers/enter_room_provider.dart';

class RoomCard extends ConsumerWidget {
  final RoomInfo roomInfo;

  const RoomCard({super.key, required this.roomInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onTap: () async {
              final EnterRoomNotifier notifier = ref.read(
                enterRoomProvider.notifier,
              );

              final EnterRoomResult? result = await notifier.enterRoom(
                roomInfo.roomId,
              );
              if (!context.mounted) return;

              if (ref.read(enterRoomProvider) == EnterRoomStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("enter room failed")),
                );
                return;
              }

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
