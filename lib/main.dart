import 'dart:io';

import 'package:client_f/providers/message_provider.dart';
import 'package:client_f/providers/nav_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    window_size.setWindowMinSize(const Size(400, 700));
    window_size.setWindowMaxSize(const Size(400, 1000));

    window_size.setWindowFrame(const Rect.fromLTWH(1500, 100, 200, 400));
  }
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => NavProvider()),
      ChangeNotifierProvider(create: (_) => MessageProvider()),
    ],
    child: const MyApp(),
  ));
}