import 'package:flutter/material.dart';

class NavState extends ChangeNotifier {
  static NavState? instance;
  int index = 0;
  NavState() {
    instance = this;
  }

  void setIndex(int i) {
    index = i;
    notifyListeners();
  }
}