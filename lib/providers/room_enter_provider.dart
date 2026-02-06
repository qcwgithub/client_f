import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/server.dart';

class RoomEnterNotifier extends StateNotifier<bool> {
  RoomEnterNotifier() : super(false);

  Future<bool> enterRoom(int roomId) async {
    if (state) return false;

    state = true; // entering

    var msg = MsgEnterRoom(roomId: roomId, lastMessageId: 0);
    MyResponse r = await Server.instance.request(MsgType.enterRoom, msg);
    state = false; // not loading

    if (r.e != ECode.success){
      return false;
    }

    var res = ResEnterRoom.fromMsgPack(r.res!);

    return r.e == ECode.success;
  }
}

final roomEnterProvider = StateNotifierProvider<RoomEnterNotifier, bool>(
  (ref) => RoomEnterNotifier()
);