import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
// import 'package:scene_hub/gen/chat_message.dart';
// import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/room.dart';
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

    var recentMessages = <ClientChatMessage>[];
    for (int i = 0; i < res.recentMessages.length; i++) {
      recentMessages.add(
        ClientChatMessage(
          inner: res.recentMessages[i],
          clientStatus: ClientChatMessageStatus.normal,
          useClientId: false,
        ),
      );
    }

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
