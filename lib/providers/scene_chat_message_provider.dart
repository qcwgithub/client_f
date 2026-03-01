import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';

final sceneChatMessageProvider =
    Provider.family<ClientChatMessage, (int, bool, int)>((ref, params) {
      final (int roomId, bool useClientId, int messageId) = params;
      ChatMessagesModel model = ref.watch(sceneChatMessagesProvider(roomId));

      int index = model.findMessageIndex(useClientId, messageId, true);
      return model.getMessageAt(index);
    });
