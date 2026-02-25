import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/scene_room_info.dart';
import 'package:scene_hub/pages/scene_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:scene_hub/providers/enter_scene_provider.dart';
import 'package:scene_hub/providers/scene_messages_provider.dart';
import 'package:scene_hub/sc.dart';

class SceneCard extends ConsumerWidget {
  final SceneRoomInfo roomInfo;

  const SceneCard({super.key, required this.roomInfo});

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
              final EnterSceneNotifier notifier = ref.read(
                enterSceneProvider.notifier,
              );

              final success = await notifier.enterScene(roomInfo.roomId);
              if (!context.mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("enter scene failed")),
                );
                return;
              }

              ref
                  .read(sceneMessagesProvider(roomInfo.roomId).notifier)
                  .setInitialMessages(
                    ref.read(enterSceneProvider).recentMessages,
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return SceneChatPage(roomInfo: roomInfo);
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
