import 'package:scene_hub/i_to_msg_pack.dart';

class ResRejectAddFriend implements IToMsgPack {
    ResRejectAddFriend();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResRejectAddFriend.fromMsgPack(List list) {
      return ResRejectAddFriend(
      );
    }
}