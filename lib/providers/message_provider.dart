import 'package:flutter/material.dart';
import 'package:scene_hub/me.dart';

class MessageItem {
  String messageId;
  String? roomId;

  // sender
  String senderId;
  String? senderName;
  String? senderAvatarUrl;

  // system
  // text
  // image
  // join
  // leave
  String type;
  String content;

  // millisecond
  int timestamp;

  MessageItem({
    required this.messageId,
    required this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    required this.type,
    required this.content,
    required this.timestamp,
  });
}

class MessageProvider extends ChangeNotifier {
  final List<MessageItem> _messageItems = [];
  List<MessageItem> get messageItems => _messageItems;

  int _max = 10000;
  int _current = 10000;
  static int pageCount = 20;
  static int latesetTimeS = 1763955346;
  static String defaultAvatarUrl =
      "https://gips3.baidu.com/it/u=2776647388,3101487920&fm=3074&app=3074&f=PNG?w=2048&h=2048";

  static MessageProvider? instance;

  MessageProvider() {
    instance = this;
    for (int i = 0; i < pageCount; i++) {
      var item = MessageItem(
        messageId: _current.toString(),
        senderId: _current.toString(),
        senderAvatarUrl: defaultAvatarUrl,
        type: "text",
        content: _current.toString() + (i == pageCount - 1 ? "(page end)" : ""),
        timestamp: (latesetTimeS - (_max - _current) * 60) * 1000,
      );
      _messageItems.insert(0, item);
      _current--;
    }
  }

  bool _isLoading = false;
  Future<bool> loadOlderMessages(void Function() beforeNotify) async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;

    // await Future.delayed(Duration(seconds: 2));

    int addCount = 0;

    for (int i = 0; i < pageCount; i++) {
      if (_current <= 0) {
        break;
      }

      var item = MessageItem(
        messageId: _current.toString(),
        senderId: _current.toString(),
        senderAvatarUrl: defaultAvatarUrl,
        type: "text",
        content:
            _current.toString() +
            (_current == 1 || i == pageCount - 1 ? "(page end)" : ""),
        timestamp: (latesetTimeS - (_max - _current) * 60) * 1000,
      );
      _messageItems.insert(0, item);
      _current--;
      addCount++;
    }

    _isLoading = false;
    if (addCount > 0) {
      beforeNotify();
      notifyListeners();
    }

    return true;
  }

  void fireNotifyListeners() {
    notifyListeners();
  }

  void sendMessage(String text) {
    var item = MessageItem(
      messageId: "messageId",
      senderId: Me.instance!.userId,
      senderAvatarUrl: defaultAvatarUrl,
      timestamp: DateTime.now().millisecondsSinceEpoch.toInt(),
      type: "text",
      content: text,
    );
    _messageItems.add(item);
    notifyListeners();
  }
}
