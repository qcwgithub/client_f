import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';

enum ClientChatMessageStatus { normal, sending, failed }

class ClientChatMessage {
  ChatMessage inner;
  ClientChatMessageStatus clientStatus;
  bool useClientSeq;
  ClientChatMessage({
    required this.inner,
    required this.clientStatus,
    required this.useClientSeq,
  });

  factory ClientChatMessage.server({required ChatMessage inner}) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: ClientChatMessageStatus.normal,
      useClientSeq: false,
    );
  }

  factory ClientChatMessage.client({
    required ChatMessage inner,
    required ClientChatMessageStatus clientStatus,
  }) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: clientStatus,
      useClientSeq: true,
    );
  }

  int get seq => inner.seq;
  int get roomId => inner.roomId;
  int get senderId => inner.senderId;
  String get senderName => inner.senderName;
  ChatMessageType get type => inner.type;
  String get content => inner.content;
  int get timestamp => inner.timestamp;
  int get clientSeq => inner.clientSeq;
  ChatMessageStatus get status => inner.status;
  int get senderAvatarIndex => inner.senderAvatarIndex;

  ClientChatMessage copyWith({ClientChatMessageStatus? clientStatus}) {
    return ClientChatMessage(
      inner: inner,
      clientStatus: clientStatus ?? this.clientStatus,
      useClientSeq: useClientSeq,
    );
  }
}
