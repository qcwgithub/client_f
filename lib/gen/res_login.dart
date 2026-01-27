import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/user_info.dart';

class ResLogin implements IToMsgPack {
    // [0]
    bool isNewUser;
    // [1]
    UserInfo userInfo;
    // [2]
    bool kickOther;

    ResLogin({
      required this.isNewUser,
      required this.userInfo,
      required this.kickOther,
    });

    @override
    List toMsgPack() {
      return [
        isNewUser,
        userInfo.toMsgPack(),
        kickOther,
      ];
    }

    factory ResLogin.fromMsgPack(List list) {
      return ResLogin(
        isNewUser: list[0] as bool,
        userInfo: UserInfo.fromMsgPack(list[1] as List),
        kickOther: list[2] as bool,
      );
    }
}