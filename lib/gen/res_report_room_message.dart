import 'package:scene_hub/i_to_msg_pack.dart';

class ResReportRoomMessage implements IToMsgPack {
    ResReportRoomMessage();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResReportRoomMessage.fromMsgPack(List list) {
      return ResReportRoomMessage(
      );
    }
}