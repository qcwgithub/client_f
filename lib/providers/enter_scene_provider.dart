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
  final List<ClientChatMessage> recentMessages;
  final EnterSceneStatus status;

  const EnterSceneModel({required this.recentMessages, required this.status});

  factory EnterSceneModel.initial() {
    return const EnterSceneModel(
      recentMessages: [],
      status: EnterSceneStatus.idle,
    );
  }

  EnterSceneModel copyWith({
    List<ClientChatMessage>? recentMessages,
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

    int min = -1;
    int max = -1;

    var recentMessages = <ClientChatMessage>[];
    for (int i = 0; i < res.recentMessages.length; i++) {
      ChatMessage m = res.recentMessages[i];
      if (min == -1 || m.seq < min) {
        min = m.seq;
      }
      if (max == -1 || m.seq > max) {
        max = m.seq;
      }
      recentMessages.add(
        ClientChatMessage(
          inner: m,
          clientStatus: ClientChatMessageStatus.normal,
          useClientId: false,
        ),
      );
    }
    sc.logger.d("enterScene ok, recentMessages messageId range [$min, $max]");

    state = state.copyWith(
      recentMessages: recentMessages,
      status: EnterSceneStatus.idle,
    );

    return true;
  }
}

final enterSceneProvider =
    StateNotifierProvider<EnterSceneNotifier, EnterSceneModel>(
      (ref) => EnterSceneNotifier(),
    );
