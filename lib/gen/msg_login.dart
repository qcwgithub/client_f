import 'package:scene_hub/i_to_msg_pack.dart';

class MsgLogin implements IToMsgPack {
    // [0]
    String version;
    // [1]
    String platform;
    // [2]
    String channel;
    // [3]
    String channelUserId;
    // [4]
    String verifyData;
    // [5]
    int userId;
    // [6]
    String token;
    // [7]
    String deviceUid;
    // [8]
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

    @override
    List toMsgPack() {
      return [
        version,
        platform,
        channel,
        channelUserId,
        verifyData,
        userId,
        token,
        deviceUid,
        dict,
      ];
    }

    factory MsgLogin.fromMsgPack(List list) {
      return MsgLogin(
        version: list[0] as String,
        platform: list[1] as String,
        channel: list[2] as String,
        channelUserId: list[3] as String,
        verifyData: list[4] as String,
        userId: list[5] as int,
        token: list[6] as String,
        deviceUid: list[7] as String,
        dict: (list[8] as Map)
          .map((k, v) => MapEntry(k as String, v as String)),
      );
    }
}