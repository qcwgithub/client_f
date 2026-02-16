import 'package:scene_hub/i_to_msg_pack.dart';

class ResRejectFriendRequest implements IToMsgPack {
    ResRejectFriendRequest();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResRejectFriendRequest.fromMsgPack(List list) {
      return ResRejectFriendRequest(
      );
    }
}