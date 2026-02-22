import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/message_report_reason.dart';

class MsgReportMessage implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int seq;
    // [2]
    MessageReportReason reason;

    MsgReportMessage({
      required this.roomId,
      required this.seq,
      required this.reason,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        seq,
        reason.code,
      ];
    }

    factory MsgReportMessage.fromMsgPack(List list) {
      return MsgReportMessage(
        roomId: list[0] as int,
        seq: list[1] as int,
        reason: MessageReportReason.fromCode(list[2] as int),
      );
    }
}