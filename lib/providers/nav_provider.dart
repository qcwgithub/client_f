import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int index = 0;

  void setIndex(int i) {
    index = i;
    notifyListeners();
  }
}