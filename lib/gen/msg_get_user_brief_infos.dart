import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetUserBriefInfos implements IToMsgPack {
    // [0]
    Set<int> userIds;

    MsgGetUserBriefInfos({
      required this.userIds,
    });

    @override
    List toMsgPack() {
      return [
        userIds,
      ];
    }

    factory MsgGetUserBriefInfos.fromMsgPack(List list) {
      return MsgGetUserBriefInfos(
        userIds: Set<int>.from(list[0]),
      );
    }
}