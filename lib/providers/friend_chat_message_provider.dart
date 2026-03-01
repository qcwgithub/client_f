import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';

/// params: (friendUserId, roomId, useClientId, seq)
final friendChatMessageProvider =
    Provider.family<ClientChatMessage, (int, int, bool, int)>((ref, params) {
      final (int friendUserId, int roomId, bool useClientId, int seq) = params;

      return ref.watch(
        friendChatMessagesProvider((friendUserId, roomId)).select((model) {
          int index = model.findMessageIndex(useClientId, seq, true);
          return model.getMessageAt(index);
        }),
      );
    });
