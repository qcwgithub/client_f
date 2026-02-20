import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/message_report_reason.dart';

class MsgReportMessage implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int messageId;
    // [2]
    MessageReportReason reason;

    MsgReportMessage({
      required this.roomId,
      required this.messageId,
      required this.reason,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        messageId,
        reason.code,
      ];
    }

    factory MsgReportMessage.fromMsgPack(List list) {
      return MsgReportMessage(
        roomId: list[0] as int,
        messageId: list[1] as int,
        reason: MessageReportReason.fromCode(list[2] as int),
      );
    }
}