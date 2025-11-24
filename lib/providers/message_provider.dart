import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final List<String> _messages = [];
  List<String> get messages => _messages;

  int _current = 10000;
  static int pageCount = 20;

  static MessageProvider? instance;

  MessageProvider() {
    instance = this;
    for (int i = 0; i < pageCount; i++) {
      _messages.insert(0, _current.toString() + (i == pageCount - 1 ? "(page end)" : ""));
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

      _messages.insert(0, _current.toString() + (_current == 1 || i == pageCount - 1 ? "(page end)" : ""));
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

  void sendMessage(String msg) {
    _messages.add(msg);
    notifyListeners();
  }
}
