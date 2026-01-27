import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/user_report_reason.dart';

class MsgReportUser implements IToMsgPack {
    // [0]
    int targetUserId;
    // [1]
    UserReportReason reason;

    MsgReportUser({
      required this.targetUserId,
      required this.reason,
    });

    @override
    List toMsgPack() {
      return [
        targetUserId,
        reason.code,
      ];
    }

    factory MsgReportUser.fromMsgPack(List list) {
      return MsgReportUser(
        targetUserId: list[0] as int,
        reason: UserReportReason.fromCode(list[1] as int),
      );
    }
}