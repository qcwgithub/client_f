import 'package:scene_hub/gen/user_info.dart';

class Me {
  static Me? instance;

  bool isMe(String userId) {
    return this.userId == userId;
  }

  UserInfo? _userInfo;
  UserInfo get userInfo {
    return _userInfo!;
  }

  void setUserInfo(UserInfo userInfo) {
    _userInfo = userInfo;
  }

  int get userId {
    return _userInfo!.userId;
  }

  String get userName {
    return _userInfo!.userName;
  }
}
