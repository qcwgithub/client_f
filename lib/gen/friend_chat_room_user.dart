import 'package:scene_hub/i_to_msg_pack.dart';

class FriendChatRoomUser implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int joinTimeS;

    FriendChatRoomUser({
      required this.userId,
      required this.joinTimeS,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        joinTimeS,
      ];
    }

    factory FriendChatRoomUser.fromMsgPack(List list) {
      return FriendChatRoomUser(
        userId: list[0] as int,
        joinTimeS: list[1] as int,
      );
    }
}