import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/outgoing_friend_request.dart';

class ResSendFriendRequest implements IToMsgPack {
    // [0]
    OutgoingFriendRequest req;

    ResSendFriendRequest({
      required this.req,
    });

    @override
    List toMsgPack() {
      return [
        req.toMsgPack(),
      ];
    }

    factory ResSendFriendRequest.fromMsgPack(List list) {
      return ResSendFriendRequest(
        req: OutgoingFriendRequest.fromMsgPack(list[0] as List),
      );
    }
}