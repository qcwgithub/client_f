import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:scene_hub/sc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'my_app.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    window_size.setWindowMinSize(const Size(400, 700));
    window_size.setWindowMaxSize(const Size(400, 1000));

    window_size.setWindowFrame(const Rect.fromLTWH(1500, 100, 200, 400));
  }

  sc.init();

  runApp(const AppRoot()); // uses UncontrolledProviderScope instead of ProviderScope
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: appRebuildNotifier,
      builder: (context, value, __) {
        return UncontrolledProviderScope(
          key: ValueKey(value),
          container: sc.container,
          child: const MyApp(),
        );
      },
    );
  }
}
