import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

class SceneChatMessagesNotifier extends ChatMessagesNotifier {
  SceneChatMessagesNotifier(int roomId)
    : super(sc.sceneChatMessageManager, roomId);
}

final sceneChatMessagesProvider =
    StateNotifierProvider.family<
      SceneChatMessagesNotifier,
      ChatMessagesModel,
      int
    >((ref, roomId) {
      final notifier = SceneChatMessagesNotifier(roomId);
      return notifier;
    });
