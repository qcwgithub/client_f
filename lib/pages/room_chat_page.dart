import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/msg_leave_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/room_info_page.dart';
import 'package:scene_hub/providers/room_messages_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/chat_input.dart';
import 'package:scene_hub/widgets/room_chat_message_item.dart';
import 'package:flutter/material.dart';

class RoomChatPage extends ConsumerStatefulWidget {
  final RoomInfo roomInfo;
  int get roomId => roomInfo.roomId;

  const RoomChatPage({super.key, required this.roomInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends ConsumerState<RoomChatPage> {
  final ScrollController _scrollController = ScrollController();
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _scrollController.addListener(() async {
      bool isTop =
          _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0;

      if (isTop) {
        // print("isTop!");
        // double beforePixels = _scrollController.position.pixels;
        // double beforeExtent = 0;
        bool loaded = await ref
            .read(roomMessagesProvider(widget.roomId).notifier)
            .requestHistory(() {
              // beforeExtent = _scrollController.position.maxScrollExtent;
            });

        // if (loaded) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     double afterExtent = _scrollController.position.maxScrollExtent;
        //     double diff = afterExtent - beforeExtent;
        //     _scrollController.jumpTo(beforePixels + diff);
        //     print(
        //       "extent ${beforeExtent} -> ${afterExtent} jumpTo ${beforePixels + diff}",
        //     );
        //   });
        // }
      }
    });
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 0),
      curve: Curves.linear,
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final RoomMessagesModel model = ref.watch(
      roomMessagesProvider(widget.roomId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomInfo.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomInfoPage(roomInfo: widget.roomInfo),
                ),
              );
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Column(
        children: [
          _buildChatList(model),
          ChatInput(
            controller: _inputController,
            callback: (type, content) {
              ref
                  .read(roomMessagesProvider(widget.roomId).notifier)
                  .sendChat(type, content, 0);
              // messageProvider.sendMessage(type, content);

              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   _scrollToBottom();
              // });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(RoomMessagesModel model) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // !
        itemCount: model.messages.length,
        itemBuilder: (context, index) {
          int L = model.messages.length;
          int itemIndex = L - 1 - index;
          ClientChatMessage message = model.messages[itemIndex];
          bool showTime = true;

          if (itemIndex < L - 1) {
            var prev = model.messages[itemIndex + 1];
            if (sc.me.isMe(message.senderId) == sc.me.isMe(prev.senderId) &&
                message.timestamp - prev.timestamp < 300000) {
              showTime = false;
            }
          }

          return RoomChatMessageItem(
            key: ValueKey(
              message.useClientId ? message.clientMessageId : message.messageId,
            ),
            roomId: widget.roomId,
            useClientId: message.useClientId,
            messageId: message.useClientId
                ? message.clientMessageId
                : message.messageId,
            showTime: showTime,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO retry!
    sc.server.request(MsgType.leaveRoom, MsgLeaveRoom(roomId: widget.roomId));
    super.dispose();
  }
}
