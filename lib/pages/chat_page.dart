import 'package:client_f/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("TODO")),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: messageProvider.messageStream, 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final msgs = snapshot.data!;
                return ListView.builder(
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(msgs[index]),
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ), 
          _buildInput(messageProvider)
        ]
      ),
    );
  }

  Widget _buildInput(MessageProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                return;
              }

              provider.sendMessage(controller.text.trim());
              controller.clear();
            },
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
