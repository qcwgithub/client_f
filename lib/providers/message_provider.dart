import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final List<String> _messages = [
    "你问得很对！",
    "正常消息流确实应该一次 add 一条消息，而不是把整个列表 add 出去。",
    "我之前那样写，是为了让 UI 每次都能拿到“全量消息列表”更容易构建 ListView。",
    "但如果你希望：",
    "每条消息 独立 push",
    "UI 端自己 append",
    "更接近真实 WebSocket / Firebase 的行为",
    "那应该这样写",
    "这是官方推荐的方式，原因：",
    "更像真正的 package 导入",
    "无论你在 lib 里的文件怎么移动，都不会出现相对路径地狱",
    "在 IDE 中重构、跳转、跨模块搜索更稳定",
    "你担心的问题其实 Flutter 已经解决了。",
    "如果你修改 pubspec.yaml 的 name: 值：",
    "例如从：",
  ];
  List<String> get messages => _messages;

  void sendMessage(String msg) {
    _messages.add(msg);
    notifyListeners();
  }
}
