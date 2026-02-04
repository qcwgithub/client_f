import 'package:flutter/material.dart';

class RoomMessageListState extends ChangeNotifier {
  static RoomMessageListState? instance;
  RoomMessageListState() {
    instance = this;
  }
}