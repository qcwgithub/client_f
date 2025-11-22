import 'package:client_f/providers/message_provider.dart';
import 'package:client_f/widgets/chat_input.dart';
import 'package:client_f/widgets/chat_message_item.dart';
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
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.sceneName)),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messageProvider.messages.length,
              itemBuilder: (context, index) =>
                  ChatMessageItem(message: messageProvider.messages[index]),
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
