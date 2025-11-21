import 'contacts_page.dart';
import 'explore_page.dart';
import 'main_page.dart';
import 'profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  
  final List<Widget> pages = const [
    MainPage(),
    ContactsPage(),
    ExplorePage(),
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
            icon: Icon(Icons.contacts_outlined), 
            selectedIcon: Icon(Icons.contacts),
            label: "Contacts"
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined), 
            selectedIcon: Icon(Icons.explore),
            label: "Explore"
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