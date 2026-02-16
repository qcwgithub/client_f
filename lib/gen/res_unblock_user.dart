import 'package:scene_hub/i_to_msg_pack.dart';

class ResUnblockUser implements IToMsgPack {
    ResUnblockUser();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResUnblockUser.fromMsgPack(List list) {
      return ResUnblockUser(
      );
    }
}