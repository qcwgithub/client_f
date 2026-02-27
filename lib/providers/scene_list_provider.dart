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

enum SceneListStatus { idle, refreshing, success, empty, error }

class SceneListModel {
  final List<SceneRoomInfo> roomInfos;
  final SceneListStatus status;

  const SceneListModel({required this.roomInfos, required this.status});

  factory SceneListModel.initial() {
    return SceneListModel(roomInfos: [], status: SceneListStatus.idle);
  }

  SceneListModel copyWith({
    List<SceneRoomInfo>? roomInfos,
    SceneListStatus? status,
  }) {
    return SceneListModel(
      roomInfos: roomInfos ?? this.roomInfos,
      status: status ?? this.status,
    );
  }
}

class SceneListNotifier extends StateNotifier<SceneListModel> {
  SceneListNotifier() : super(SceneListModel.initial());

  Future<bool> getRecommendedScenes() async {
    if (state.status == SceneListStatus.refreshing) return false;

    state = state.copyWith(status: SceneListStatus.refreshing);

    final r = await sc.server.request(
      MsgType.getRecommendedScenes,
      MsgGetRecommendedScenes(),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: SceneListStatus.error);
      return false;
    }

    final res = ResGetRecommendedScenes.fromMsgPack(r.res!);

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: SceneListStatus.empty);
    } else {
      state = state.copyWith(
        roomInfos: res.roomInfos,
        status: SceneListStatus.idle,
      );
    }
    return true;
  }

  Future<void> search(String keyword) async {
    if (state.status == SceneListStatus.refreshing) return;

    state = state.copyWith(status: SceneListStatus.refreshing);

    MyResponse r = await sc.server.request(
      MsgType.searchScene,
      MsgSearchScene(keyword: keyword),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: SceneListStatus.error);
      return;
    }

    var res = ResSearchScene.fromMsgPack(r.res!);
    final scenes = res.roomInfos;

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: SceneListStatus.empty);
    } else {
      state = state.copyWith(roomInfos: scenes, status: SceneListStatus.idle);
    }
  }
}

final sceneListProvider =
    StateNotifierProvider<SceneListNotifier, SceneListModel>(
      (ref) => SceneListNotifier(),
    );
