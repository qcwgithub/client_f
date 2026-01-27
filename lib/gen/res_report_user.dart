import 'package:scene_hub/i_to_msg_pack.dart';

class ResReportUser implements IToMsgPack {
    ResReportUser();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResReportUser.fromMsgPack(List list) {
      return ResReportUser(
      );
    }
}