import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_recommended_scenes.dart';
import 'package:scene_hub/gen/msg_search_scene.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_recommended_scenes.dart';
import 'package:scene_hub/gen/res_search_scene.dart';
import 'package:scene_hub/gen/scene_room_info.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/sc.dart';

enum SceneRoomListStatus { idle, refreshing, success, empty, error }

class SceneRoomListModel {
  final List<SceneRoomInfo> roomInfos;
  final SceneRoomListStatus status;

  const SceneRoomListModel({required this.roomInfos, required this.status});

  factory SceneRoomListModel.initial() {
    return SceneRoomListModel(roomInfos: [], status: SceneRoomListStatus.idle);
  }

  SceneRoomListModel copyWith({
    List<SceneRoomInfo>? roomInfos,
    SceneRoomListStatus? status,
  }) {
    return SceneRoomListModel(
      roomInfos: roomInfos ?? this.roomInfos,
      status: status ?? this.status,
    );
  }
}

class SceneListNotifier extends StateNotifier<SceneRoomListModel> {
  SceneListNotifier() : super(SceneRoomListModel.initial());

  Future<bool> getRecommendedScenes() async {
    if (state.status == SceneRoomListStatus.refreshing) return false;

    state = state.copyWith(status: SceneRoomListStatus.refreshing);

    final r = await sc.server.request(
      MsgType.getRecommendedScenes,
      MsgGetRecommendedScenes(),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: SceneRoomListStatus.error);
      return false;
    }

    final res = ResGetRecommendedScenes.fromMsgPack(r.res!);

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: SceneRoomListStatus.empty);
    } else {
      state = state.copyWith(
        roomInfos: res.roomInfos,
        status: SceneRoomListStatus.idle,
      );
    }
    return true;
  }

  Future<void> search(String keyword) async {
    if (state.status == SceneRoomListStatus.refreshing) return;

    state = state.copyWith(status: SceneRoomListStatus.refreshing);

    MyResponse r = await sc.server.request(
      MsgType.searchScene,
      MsgSearchScene(keyword: keyword),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: SceneRoomListStatus.error);
      return;
    }

    var res = ResSearchScene.fromMsgPack(r.res!);
    final scenes = res.roomInfos;

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: SceneRoomListStatus.empty);
    } else {
      state = state.copyWith(roomInfos: scenes, status: SceneRoomListStatus.idle);
    }
  }
}

final sceneListProvider =
    StateNotifierProvider<SceneListNotifier, SceneRoomListModel>(
      (ref) => SceneListNotifier(),
    );
