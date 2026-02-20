import 'package:scene_hub/i_to_msg_pack.dart';

class ResReportMessage implements IToMsgPack {
    ResReportMessage();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResReportMessage.fromMsgPack(List list) {
      return ResReportMessage(
      );
    }
}