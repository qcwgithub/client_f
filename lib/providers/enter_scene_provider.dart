import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/sc.dart';

enum EnterSceneStatus { idle, loading }

class EnterSceneModel {
  final EnterSceneStatus status;

  const EnterSceneModel({required this.status});

  factory EnterSceneModel.initial() {
    return const EnterSceneModel(status: EnterSceneStatus.idle);
  }

  EnterSceneModel copyWith({EnterSceneStatus? status}) {
    return EnterSceneModel(status: status ?? this.status);
  }
}

class EnterSceneNotifier extends StateNotifier<EnterSceneModel> {
  EnterSceneNotifier() : super(EnterSceneModel.initial());

  Future<bool> enterScene(int roomId) async {
    if (state.status == EnterSceneStatus.loading) {
      return false;
    }

    state = state.copyWith(status: EnterSceneStatus.loading);

    final success = await sc.sceneChatMessageManager.requestEnterScene(roomId);
    state = state.copyWith(status: EnterSceneStatus.idle);

    return success;
  }
}

final enterSceneProvider =
    StateNotifierProvider<EnterSceneNotifier, EnterSceneModel>(
      (ref) => EnterSceneNotifier(),
    );
