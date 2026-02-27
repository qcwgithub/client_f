import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';

/// params: (friendUserId, roomId, useClientId, messageId)
final friendChatMessageProvider =
    Provider.family<ClientChatMessage, (int, int, bool, int)>((ref, params) {
  final (int friendUserId, int roomId, bool useClientId, int messageId) = params;
  FriendChatMessagesModel model = ref.watch(
    friendChatMessagesProvider((friendUserId, roomId)),
  );

  int index = model.findMessageIndex(useClientId, messageId, true);
  return model.getMessageAt(index);
});
