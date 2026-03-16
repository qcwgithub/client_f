import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';

ClientChatMessage? _errorMessage;

final sceneChatMessageProvider =
    Provider.family<ClientChatMessage, (int, bool, int)>((ref, params) {
      final (int roomId, bool useClientSeq, int seq) = params;

      return ref.watch(
        sceneChatMessagesProvider(roomId).select((model) {
          bool logErrorIfNotExist = false; // trim 时，会报错，因此要设置为 false
          int index = model.findMessageIndex(useClientSeq, seq, logErrorIfNotExist);
          if (index == -1) {
            _errorMessage ??= ClientChatMessage(
              inner: ChatMessage(
                seq: seq,
                roomId: roomId,
                senderId: 0,
                senderName: "",
                senderAvatar: "",
                type: ChatMessageType.text,
                content: "ERROR",
                timestamp: 0,
                replyTo: 0,
                senderAvatarIndex: 0,
                clientSeq: useClientSeq ? seq : 0,
                status: ChatMessageStatus.normal,
                imageContent: null,
              ),
              clientStatus: ClientChatMessageStatus.normal,
              useClientSeq: useClientSeq,
            );
            return _errorMessage!;
          }
          return model.getMessageAt(index);
        }),
      );
    });
