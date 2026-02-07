import 'package:scene_hub/gen/user_info.dart';

class Me {
  bool isMe(int userId) {
    return this.userId == userId;
  }

  UserInfo? _userInfo;
  UserInfo get userInfo {
    return _userInfo!;
  }

  set userInfo(UserInfo value) {
    _userInfo = value;
  }

  bool isNewUser = false;

  int get userId {
    return _userInfo!.userId;
  }

  String get userName {
    return _userInfo!.userName;
  }
}
