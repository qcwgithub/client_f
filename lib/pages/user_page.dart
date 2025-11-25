import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final String userId;
  final String? userName;
  final String? avatarUrl;
  const UserPage({
    super.key,
    required this.userId,
    this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Info")),
      body: Center(child: Text(userName ?? "(No name)")),
    );
  }
}
