import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/friend_request_result.dart';

class OutgoingFriendRequest implements IToMsgPack {
    // [0]
    int toUserId;
    // [1]
    int timeS;
    // [2]
    String say;
    // [3]
    FriendRequestResult result;

    OutgoingFriendRequest({
      required this.toUserId,
      required this.timeS,
      required this.say,
      required this.result,
    });

    @override
    List toMsgPack() {
      return [
        toUserId,
        timeS,
        say,
        result.code,
      ];
    }

    factory OutgoingFriendRequest.fromMsgPack(List list) {
      return OutgoingFriendRequest(
        toUserId: list[0] as int,
        timeS: list[1] as int,
        say: list[2] as String,
        result: FriendRequestResult.fromCode(list[3] as int),
      );
    }
}