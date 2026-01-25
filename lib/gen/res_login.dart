import 'package:scene_hub/gen/user_info.dart';

class ResLogin {
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

    List toMsgPack() {
      return [
        isNewUser,
        UserInfo.toMsgPack(),
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