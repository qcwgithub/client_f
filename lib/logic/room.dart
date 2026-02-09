import 'package:scene_hub/gen/a__msg_room_chat.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_room_chat_history.dart';
import 'package:scene_hub/gen/msg_report_room_message.dart';
import 'package:scene_hub/gen/msg_send_room_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_room_chat_history.dart';
// import 'package:scene_hub/gen/res_send_room_chat.dart';
// import 'package:scene_hub/gen/res_report_room_message.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/gen/room_message_report_reason.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

class Room {
  final RoomInfo roomInfo;
  final List<ClientChatMessage> messages = [];
  final List<ClientChatMessage> sendings = [];
  Room({required this.roomInfo, required List<ChatMessage> recentMessages}) {
    for (int i = 0; i < recentMessages.length; i++) {
      messages.add(
        ClientChatMessage(
          inner: recentMessages[i],
          clientStatus: ClientChatMessageStatus.normal,
          useClientId: false,
        ),
      );
    }
  }

  int get roomId {
    return roomInfo.roomId;
  }

  ClientChatMessage createSending(
    ChatMessageType type,
    String content,
    int replyTo,
  ) {
    int clientMessageId = clientMessageIdGenerator.nextId();
    final inner = ChatMessage(
      messageId: 0,
      roomId: roomId,
      senderId: sc.me.userId,
      senderName: sc.me.userName,
      senderAvatar: "",
      type: type,
      content: content,
      timestamp: TimeUtils.now(),
      replyTo: replyTo,
      senderAvatarIndex: sc.me.userInfo.avatarIndex,
      clientMessageId: clientMessageId,
      status: ChatMessageStatus.normal,
    );
    final message = ClientChatMessage(
      inner: inner,
      clientStatus: ClientChatMessageStatus.sending,
      useClientId: true,
    );

    return message;
  }

  Future<bool> sendChat(ClientChatMessage message) async {
    assert(message.clientStatus == ClientChatMessageStatus.sending);
    sendings.add(message);

    var msg = MsgSendRoomChat(
      roomId: roomId,
      chatMessageType: message.type,
      content: message.content,
      clientMessageId: message.clientMessageId,
    );

    final r = await sc.server.request(MsgType.sendRoomChat, msg);
    sendings.remove(message);

    if (r.e != ECode.success) {
      message.clientStatus = ClientChatMessageStatus.failed;
      return false;
    }

    // final res = ResSendRoomChat.fromMsgPack(r.res!);
    return true;
  }

  Future<bool> getChatHistory() async {
    int last = 0;
    if (messages.isNotEmpty) {
      last = messages[0].messageId;
    }
    var msg = MsgGetRoomChatHistory(roomId: roomId, lastMessageId: last);

    final r = await sc.server.request(MsgType.getRoomChatHistory, msg);
    if (r.e != ECode.success) {
      return false;
    }

    var res = ResGetRoomChatHistory.fromMsgPack(r.res!);
    for (int i = 0; i < res.history.length; i++) {
      final message = ClientChatMessage(
        inner: res.history[i],
        clientStatus: ClientChatMessageStatus.normal,
        useClientId: false,
      );
      messages.insert(0, message);
    }

    return true;
  }

  Future<bool> reportRoomMessage(
    int messageId,
    RoomMessageReportReason reason,
  ) async {
    var msg = MsgReportRoomMessage(
      roomId: roomId,
      messageId: messageId,
      reason: reason,
    );

    final r = await sc.server.request(MsgType.reportRoomMessage, msg);
    if (r.e != ECode.success) {
      return false;
    }

    // final res = ResReportRoomMessage.fromMsgPack(r.res!);

    return true;
  }

  void onChatMessage(A_MsgRoomChat msg) {}
}
