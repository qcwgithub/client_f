import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  const UserPage({super.key, required this.userName, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Info")),
      body: Center(child: Text(userName)),
    );
  }
}
