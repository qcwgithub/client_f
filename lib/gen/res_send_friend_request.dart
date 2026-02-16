import 'package:scene_hub/i_to_msg_pack.dart';

class ResSendFriendRequest implements IToMsgPack {
    ResSendFriendRequest();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSendFriendRequest.fromMsgPack(List list) {
      return ResSendFriendRequest(
      );
    }
}