import 'dart:async';

import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final List<String> _messages = [];
  List<String> get message => _messages;

  final _controller = StreamController<List<String>>.broadcast();
  Stream<List<String>> get messageStream => _controller.stream;

  void sendMessage(String msg) {
    _messages.add(msg);

    _controller.add(_messages);

    notifyListeners();
  }

  void disposeProvider() {
    _controller.close();
  }
}