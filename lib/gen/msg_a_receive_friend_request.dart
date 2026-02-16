import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/user_brief_info.dart';
import 'package:scene_hub/gen/incoming_friend_request.dart';

class MsgAReceiveFriendRequest implements IToMsgPack {
    // [0]
    UserBriefInfo fromUserBriefInfo;
    // [1]
    IncomingFriendRequest req;

    MsgAReceiveFriendRequest({
      required this.fromUserBriefInfo,
      required this.req,
    });

    @override
    List toMsgPack() {
      return [
        fromUserBriefInfo.toMsgPack(),
        req.toMsgPack(),
      ];
    }

    factory MsgAReceiveFriendRequest.fromMsgPack(List list) {
      return MsgAReceiveFriendRequest(
        fromUserBriefInfo: UserBriefInfo.fromMsgPack(list[0] as List),
        req: IncomingFriendRequest.fromMsgPack(list[1] as List),
      );
    }
}