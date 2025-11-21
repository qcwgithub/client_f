import 'create_page.dart';
import 'discover_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  
  final List<Widget> pages = const [
    HomePage(),
    DiscoverPage(),
    CreatePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined), 
            selectedIcon: Icon(Icons.home),
            label: "Home"
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined), 
            selectedIcon: Icon(Icons.explore),
            label: "Discover"
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outlined), 
            selectedIcon: Icon(Icons.add_circle),
            label: "Create"
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined), 
            selectedIcon: Icon(Icons.person),
            label: "Profile"
          ),
        ]),
    );
  }
}