import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:flutter/material.dart';
import 'package:scene_hub/pages/login_page.dart';

/// 改变此 key 会销毁内层 ProviderScope 下的所有 provider
final appScopeKeyProvider = StateProvider<UniqueKey>((_) => UniqueKey());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopeKey = ref.watch(appScopeKeyProvider);

    return ProviderScope(
      key: scopeKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // 去掉 DEBUG 横幅
        title: 'Scene Hub',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
