import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final List<String> _messages = [];
  List<String> get messages => _messages;

  int _current = 10000;
  static const int maxCache = 50;

  static MessageProvider? instance;

  MessageProvider() {
    instance = this;
    for (int i = 0; i < 20; i++) {
      _messages.insert(0, _current.toString());
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

    for (int i = 0; i < 20; i++) {
      if (_current <= 0) {
        break;
      }

      _messages.insert(0, _current.toString());
      _current--;
      addCount++;
    }

    while (_messages.length > maxCache) {
      _messages.removeLast();
    }

    _isLoading = false;
    if (addCount > 0) {
      print("[${_messages[0]}, ${_messages[_messages.length - 1]}]");

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
