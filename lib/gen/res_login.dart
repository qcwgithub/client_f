import 'package:scene_hub/gen/user_info.dart';

class ResLogin {
    bool isNewUser;
    UserInfo userInfo;
    bool kickOther;

    ResLogin({
      required this.isNewUser,
      required this.userInfo,
      required this.kickOther,
    });

    List toMsgPack() {
      return [
        isNewUser, // [0]
        UserInfo.toMsgPack(), // [1]
        kickOther, // [2]
      ];
    }

    factory ResLogin.fromMsgPack(List list) {
      return ResLogin(
        isNewUser: list[0] as bool, // [0]
        userInfo: UserInfo.fromMsgPack(list[1] as List), // [1]
        kickOther: list[2] as bool, // [2]
      );
    }
}