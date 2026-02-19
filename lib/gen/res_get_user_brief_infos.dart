import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/user_brief_info.dart';

class ResGetUserBriefInfos implements IToMsgPack {
    // [0]
    List<UserBriefInfo> userBriefInfos;

    ResGetUserBriefInfos({
      required this.userBriefInfos,
    });

    @override
    List toMsgPack() {
      return [
        userBriefInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetUserBriefInfos.fromMsgPack(List list) {
      return ResGetUserBriefInfos(
        userBriefInfos: (list[0] as List)
          .map((e) => UserBriefInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}