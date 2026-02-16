import 'package:scene_hub/i_to_msg_pack.dart';

class ResAddFriend implements IToMsgPack {
    ResAddFriend();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResAddFriend.fromMsgPack(List list) {
      return ResAddFriend(
      );
    }
}