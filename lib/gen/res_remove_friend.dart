import 'package:scene_hub/i_to_msg_pack.dart';

class ResRemoveFriend implements IToMsgPack {
    ResRemoveFriend();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResRemoveFriend.fromMsgPack(List list) {
      return ResRemoveFriend(
      );
    }
}