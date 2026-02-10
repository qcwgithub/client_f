import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/pages/room_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:scene_hub/providers/enter_room_provider.dart';
import 'package:scene_hub/providers/room_message_list_provider.dart';
import 'package:scene_hub/sc.dart';

class RoomCard extends ConsumerWidget {
  final int roomId;

  const RoomCard({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomInfo = sc.roomManager.getRoomInfo(roomId)!;
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

              final success = await notifier.enterRoom(roomId);
              if (!context.mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("enter room failed")),
                );
                return;
              }

              ref
                  .read(roomMessageListProvider(roomId).notifier)
                  .setInitialMessages(
                    ref.read(enterRoomProvider).recentMessages,
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return RoomChatPage(roomId: roomId);
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
