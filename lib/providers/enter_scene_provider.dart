import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_scene.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_scene.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/sc.dart';

enum EnterSceneStatus { idle, loading }

class EnterSceneModel {
  final List<ChatMessage> recentMessages;
  final EnterSceneStatus status;

  const EnterSceneModel({required this.recentMessages, required this.status});

  factory EnterSceneModel.initial() {
    return const EnterSceneModel(
      recentMessages: [],
      status: EnterSceneStatus.idle,
    );
  }

  EnterSceneModel copyWith({
    List<ChatMessage>? recentMessages,
    EnterSceneStatus? status,
  }) {
    return EnterSceneModel(
      recentMessages: recentMessages ?? this.recentMessages,
      status: status ?? this.status,
    );
  }
}

class EnterSceneNotifier extends StateNotifier<EnterSceneModel> {
  EnterSceneNotifier() : super(EnterSceneModel.initial());

  Future<bool> enterScene(int roomId) async {
    if (state.status == EnterSceneStatus.loading) {
      return false;
    }

    state = state.copyWith(status: EnterSceneStatus.loading);

    final r = await sc.server.request(
      MsgType.enterScene,
      MsgEnterScene(roomId: roomId, lastSeq: 0),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: EnterSceneStatus.idle);
      return false;
    }

    var res = ResEnterScene.fromMsgPack(r.res!);

    state = state.copyWith(
      recentMessages: res.recentMessages,
      status: EnterSceneStatus.idle,
    );

    return true;
  }
}

final enterSceneProvider =
    StateNotifierProvider<EnterSceneNotifier, EnterSceneModel>(
      (ref) => EnterSceneNotifier(),
    );
