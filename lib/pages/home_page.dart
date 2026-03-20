import 'conversation_list_page.dart';
import 'scene_list_page.dart';
import 'profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/providers/total_conversation_unread_hint_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ConversationListPage(),
    SceneListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final totalUnread = ref.watch(totalConversationUnreadHintProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 55,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalUnread > 0,
              label: Text('$totalUnread'),
              child: const Icon(Icons.chat_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalUnread > 0,
              label: Text('$totalUnread'),
              child: const Icon(Icons.chat),
            ),
            label: "Chat",
          ),
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Scenes",
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
