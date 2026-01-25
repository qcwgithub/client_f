class UserInfo {
    int userId;
    String userName;
    int createTimeS;
    int lastLoginTimeS;
    int lastSetNameTimeS;
    int avatarIndex;
    int lastSetAvatarIndexTimeS;

    UserInfo({
      required this.userId,
      required this.userName,
      required this.createTimeS,
      required this.lastLoginTimeS,
      required this.lastSetNameTimeS,
      required this.avatarIndex,
      required this.lastSetAvatarIndexTimeS,
    });

    List toMsgPack() {
      return [
        userId, // [0]
        userName, // [1]
        createTimeS, // [2]
        lastLoginTimeS, // [3]
        lastSetNameTimeS, // [4]
        avatarIndex, // [5]
        lastSetAvatarIndexTimeS, // [6]
      ];
    }

    factory UserInfo.fromMsgPack(List list) {
      return UserInfo(
        userId: list[0] as int, // [0]
        userName: list[1] as String, // [1]
        createTimeS: list[2] as int, // [2]
        lastLoginTimeS: list[3] as int, // [3]
        lastSetNameTimeS: list[4] as int, // [4]
        avatarIndex: list[5] as int, // [5]
        lastSetAvatarIndexTimeS: list[6] as int, // [6]
      );
    }
}