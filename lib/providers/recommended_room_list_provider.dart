import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_recommended_rooms.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_recommended_rooms.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/server.dart';

class RecommendedRoomListNotifier
    extends StateNotifier<AsyncValue<List<RoomInfo>>> {
  RecommendedRoomListNotifier() : super(const AsyncValue.loading());

  Future<void> refresh() async {
    if (state is AsyncLoading) return;

    state = const AsyncValue.loading();

    MyResponse r = await Server.instance.request(
      MsgType.getRecommendedRooms,
      MsgGetRecommendedRooms(),
    );

    if (r.e != ECode.success) {
      state = AsyncValue.error(r.e.toString(), StackTrace.empty);
      return;
    }

    final res = ResGetRecommendedRooms.fromMsgPack(r.res!);
    state = AsyncValue.data(res.roomInfos);
  }
}

final recommendedRoomListProvider =
    StateNotifierProvider<
      RecommendedRoomListNotifier,
      AsyncValue<List<RoomInfo>>
    >((ref) => RecommendedRoomListNotifier());
