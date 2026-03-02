import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:scene_hub/sc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'app.dart';

late final ProviderContainer globalContainer;

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  globalContainer = ProviderContainer();

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    window_size.setWindowMinSize(const Size(400, 700));
    window_size.setWindowMaxSize(const Size(400, 1000));

    window_size.setWindowFrame(const Rect.fromLTWH(1500, 100, 200, 400));
  }

  sc.init();

  runApp(
    UncontrolledProviderScope(container: globalContainer, child: const MyApp()),
  );
}
