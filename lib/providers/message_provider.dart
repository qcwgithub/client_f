import 'package:flutter/material.dart';

class MessageItem {
  final String text;
  final bool isMe;
  MessageItem({required this.text, required this.isMe});
}

class MessageProvider extends ChangeNotifier {
  final List<MessageItem> _messageItems = [];
  List<MessageItem> get messageItems => _messageItems;

  int _current = 10000;
  static int pageCount = 20;

  static MessageProvider? instance;

  MessageProvider() {
    instance = this;
    for (int i = 0; i < pageCount; i++) {
      var item = MessageItem(
        text: _current.toString() + (i == pageCount - 1 ? "(page end)" : ""),
        isMe: i % 8 == 0,
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
        text:
            _current.toString() +
            (_current == 1 || i == pageCount - 1 ? "(page end)" : ""),
        isMe: i % 8 == 0,
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
    var item = MessageItem(text: text, isMe: true);
    _messageItems.add(item);
    notifyListeners();
  }
}
