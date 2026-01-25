class MsgLogin {
    String version;
    String platform;
    String channel;
    String channelUserId;
    String verifyData;
    int userId;
    String token;
    String deviceUid;
    Map<String, String> dict;

    MsgLogin({
      required this.version,
      required this.platform,
      required this.channel,
      required this.channelUserId,
      required this.verifyData,
      required this.userId,
      required this.token,
      required this.deviceUid,
      required this.dict,
    });

    List toMsgPack() {
      return [
        version, // [0]
        platform, // [1]
        channel, // [2]
        channelUserId, // [3]
        verifyData, // [4]
        userId, // [5]
        token, // [6]
        deviceUid, // [7]
        dict, // [8]
      ];
    }

    factory MsgLogin.fromMsgPack(List list) {
      return MsgLogin(
        version: list[0] as String, // [0]
        platform: list[1] as String, // [1]
        channel: list[2] as String, // [2]
        channelUserId: list[3] as String, // [3]
        verifyData: list[4] as String, // [4]
        userId: list[5] as int, // [5]
        token: list[6] as String, // [6]
        deviceUid: list[7] as String, // [7]
        dict: (list[8] as Map)
          .map((k, v) => MapEntry(k as String, v as String)), // [8]
      );
    }
}