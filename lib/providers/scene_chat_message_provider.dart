import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';

final sceneChatMessageProvider =
    Provider.family<ClientChatMessage, (int, bool, int)>((ref, params) {
      final (int roomId, bool useClientId, int seq) = params;

      return ref.watch(
        sceneChatMessagesProvider(roomId).select((model) {
          int index = model.findMessageIndex(useClientId, seq, true);
          return model.getMessageAt(index);
        }),
      );
    });
