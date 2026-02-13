import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
// import 'package:scene_hub/gen/chat_message.dart';
// import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/room.dart';
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/sc.dart';

enum EnterRoomStatus { idle, loading }

class EnterRoomModel {
  final List<ClientChatMessage> recentMessages;
  final EnterRoomStatus status;

  const EnterRoomModel({required this.recentMessages, required this.status});

  factory EnterRoomModel.initial() {
    return const EnterRoomModel(
      recentMessages: [],
      status: EnterRoomStatus.idle,
    );
  }

  EnterRoomModel copyWith({
    List<ClientChatMessage>? recentMessages,
    EnterRoomStatus? status,
  }) {
    return EnterRoomModel(
      recentMessages: recentMessages ?? this.recentMessages,
      status: status ?? this.status,
    );
  }
}

class EnterRoomNotifier extends StateNotifier<EnterRoomModel> {
  EnterRoomNotifier() : super(EnterRoomModel.initial());

  Future<bool> enterRoom(int roomId) async {
    if (state.status == EnterRoomStatus.loading) {
      return false;
    }

    state = state.copyWith(status: EnterRoomStatus.loading);

    final r = await sc.server.request(
      MsgType.enterRoom,
      MsgEnterRoom(roomId: roomId, lastMessageId: 0),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: EnterRoomStatus.idle);
      return false;
    }

    var res = ResEnterRoom.fromMsgPack(r.res!);

    int min = -1;
    int max = -1;

    var recentMessages = <ClientChatMessage>[];
    for (int i = 0; i < res.recentMessages.length; i++) {
      ChatMessage m = res.recentMessages[i];
      if (min == -1 || m.messageId < min) {
        min = m.messageId;
      }
      if (max == -1 || m.messageId > max) {
        max = m.messageId;
      }
      recentMessages.add(
        ClientChatMessage(
          inner: m,
          clientStatus: ClientChatMessageStatus.normal,
          useClientId: false,
        ),
      );
    }
    logger.d("enterRoom ok, recentMessages messageId range [$min, $max]");

    state = state.copyWith(
      recentMessages: recentMessages,
      status: EnterRoomStatus.idle,
    );

    return true;
  }
}

final enterRoomProvider =
    StateNotifierProvider<EnterRoomNotifier, EnterRoomModel>(
      (ref) => EnterRoomNotifier(),
    );
