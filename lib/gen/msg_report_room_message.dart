import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/room_message_report_reason.dart';

class MsgReportRoomMessage implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int messageId;
    // [2]
    RoomMessageReportReason reason;

    MsgReportRoomMessage({
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

    factory MsgReportRoomMessage.fromMsgPack(List list) {
      return MsgReportRoomMessage(
        roomId: list[0] as int,
        messageId: list[1] as int,
        reason: RoomMessageReportReason.fromCode(list[2] as int),
      );
    }
}