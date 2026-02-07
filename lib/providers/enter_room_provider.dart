import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/sc.dart';

class EnterRoomResult {
  final List<ChatMessage> initialMessages;
  EnterRoomResult({required this.initialMessages});
}

enum EnterRoomStatus { idle, loading, success, error }

class EnterRoomNotifier extends StateNotifier<EnterRoomStatus> {
  EnterRoomNotifier() : super(EnterRoomStatus.idle);

  Future<EnterRoomResult?> enterRoom(int roomId) async {
    if (state == EnterRoomStatus.loading) return null;
    state = EnterRoomStatus.loading;

    var msg = MsgEnterRoom(roomId: roomId, lastMessageId: 0);
    MyResponse r = await sc.server.request(MsgType.enterRoom, msg);

    if (r.e != ECode.success) {
      state = EnterRoomStatus.error;
      return null;
    }

    var res = ResEnterRoom.fromMsgPack(r.res!);
    state = EnterRoomStatus.success;

    return EnterRoomResult(initialMessages: res.recentMessages);
  }
}

final enterRoomProvider =
    StateNotifierProvider<EnterRoomNotifier, EnterRoomStatus>(
      (ref) => EnterRoomNotifier(),
    );
