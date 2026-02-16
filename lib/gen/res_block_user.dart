import 'package:scene_hub/i_to_msg_pack.dart';

class ResBlockUser implements IToMsgPack {
    ResBlockUser();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResBlockUser.fromMsgPack(List list) {
      return ResBlockUser(
      );
    }
}