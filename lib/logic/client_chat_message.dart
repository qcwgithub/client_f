import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';

enum ClientChatMessageStatus { normal, sending, failed }

class ClientChatMessage {
  ChatMessage inner;
  ClientChatMessageStatus clientStatus;
  bool useClientId;
  ClientChatMessage({
    required this.inner,
    required this.clientStatus,
    required this.useClientId,
  });

  factory ClientChatMessage.server({required ChatMessage inner}) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: ClientChatMessageStatus.normal,
      useClientId: false,
    );
  }

  factory ClientChatMessage.client({
    required ChatMessage inner,
    required ClientChatMessageStatus clientStatus,
  }) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: clientStatus,
      useClientId: true,
    );
  }

  int get messageId => inner.messageId;
  int get roomId => inner.roomId;
  int get senderId => inner.senderId;
  String get senderName => inner.senderName;
  ChatMessageType get type => inner.type;
  String get content => inner.content;
  int get timestamp => inner.timestamp;
  int get clientMessageId => inner.clientMessageId;
  ChatMessageStatus get status => inner.status;

  ClientChatMessage copyWith({ClientChatMessageStatus? clientStatus}) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: clientStatus ?? this.clientStatus,
      useClientId: useClientId,
    );
  }
}
