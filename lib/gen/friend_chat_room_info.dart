import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/private_room_user.dart';

class FriendChatRoomInfo implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int createTimeS;
    // [2]
    int messageSeq;
    // [3]
    List<PrivateRoomUser> users;

    FriendChatRoomInfo({
      required this.roomId,
      required this.createTimeS,
      required this.messageSeq,
      required this.users,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        createTimeS,
        messageSeq,
        users.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory FriendChatRoomInfo.fromMsgPack(List list) {
      return FriendChatRoomInfo(
        roomId: list[0] as int,
        createTimeS: list[1] as int,
        messageSeq: list[2] as int,
        users: (list[3] as List)
          .map((e) => PrivateRoomUser.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}