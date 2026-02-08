import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/room.dart';
import 'package:scene_hub/sc.dart';

enum EnterRoomStatus { idle, loading }

class EnterRoomModel {
  final List<ChatMessage> recentMessages;
  final EnterRoomStatus status;

  const EnterRoomModel(this.recentMessages, this.status);

  factory EnterRoomModel.initial() {
    return const EnterRoomModel([], EnterRoomStatus.idle);
  }
}

class EnterRoomNotifier extends StateNotifier<EnterRoomModel> {
  EnterRoomNotifier() : super(EnterRoomModel.initial());

  Future<bool> enterRoom(int roomId) async {
    if (state.status == EnterRoomStatus.loading) {
      return false;
    }

    state = EnterRoomModel([], EnterRoomStatus.loading);

    bool success = await sc.roomManager.enterRoom(roomId);
    if (success) {
      Room? room = sc.roomManager.getRoom(roomId);
      if (room != null) {
        state = EnterRoomModel(room.messages, EnterRoomStatus.idle);
        return true;
      }
    }

    state = EnterRoomModel([], EnterRoomStatus.loading);
    return false;
  }
}

final enterRoomProvider =
    StateNotifierProvider<EnterRoomNotifier, EnterRoomModel>(
      (ref) => EnterRoomNotifier(),
    );
