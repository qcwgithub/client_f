import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/room_message_list_provider.dart';

final roomMessageProvider =
    Provider.family<ClientChatMessage, (int, bool, int)>((ref, params) {
      final (int roomId, bool useClientId, int messageId) = params;
      RoomMessageListModel roomMessageListModel = ref.watch(
        roomMessageListProvider(roomId),
      );

      return roomMessageListModel.findMessage(useClientId, messageId);
    });
