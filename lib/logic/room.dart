import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/room_info.dart';

class Room {
  final RoomInfo roomInfo;
  final List<ChatMessage> messages;
  Room(this.roomInfo, this.messages);

  int get roomId {
    return roomInfo.roomId;
  }
}
