import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/room_messages_provider.dart';

final roomMessageProvider =
    Provider.family<ClientChatMessage, (int, bool, int)>((ref, params) {
      final (int roomId, bool useClientId, int messageId) = params;
      RoomMessagesModel roomMessageListModel = ref.watch(
        roomMessagesProvider(roomId),
      );

      int index = roomMessageListModel.findMessageIndex(useClientId, messageId, true);
      return roomMessageListModel.getMessageAt(index)!;
    });
