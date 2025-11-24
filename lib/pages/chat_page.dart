import 'package:scene_hub/providers/message_provider.dart';
import 'package:scene_hub/widgets/chat_input.dart';
import 'package:scene_hub/widgets/chat_message_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String sceneName;

  const ChatPage({super.key, required this.sceneName});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

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
        // bool loaded =
        await MessageProvider.instance!.loadOlderMessages(() {
          // beforeExtent = _scrollController.position.maxScrollExtent;
        });

        // if (loaded) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     double afterExtent = _scrollController.position.maxScrollExtent;
        //     double diff = afterExtent - beforeExtent;
        //     _scrollController.jumpTo(beforePixels + diff);
        //     print("extent ${beforeExtent} -> ${afterExtent} jumpTo ${beforePixels + diff}");
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
    print("build");
    final messageProvider = Provider.of<MessageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.sceneName)),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // !
              itemCount: messageProvider.messageItems.length,
              itemBuilder: (context, index) {
                int L = messageProvider.messageItems.length;
                int itemIndex = L - 1 - index;
                var item = messageProvider.messageItems[itemIndex];
                int timeS = item.timeS;
                if (itemIndex < L - 1) {
                  var prevItem = messageProvider.messageItems[itemIndex + 1];
                  if (item.isMe == prevItem.isMe && timeS - prevItem.timeS < 300) {
                    timeS = 0;
                  }
                }
                return ChatMessageItem(
                  text: item.text,
                  isMe: item.isMe,
                  avatarUrl:
                      "https://gips3.baidu.com/it/u=2776647388,3101487920&fm=3074&app=3074&f=PNG?w=2048&h=2048",
                  timeS: timeS,
                  userName: "userName",
                );
              },
            ),
          ),
          ChatInput(
            callback: (msg) {
              messageProvider.sendMessage(msg);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            },
          ),
        ],
      ),
    );
  }
}
