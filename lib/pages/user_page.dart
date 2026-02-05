import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final int userId;
  final String? userName;
  const UserPage({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Info")),
      body: Center(child: Text(userName ?? "(No name)")),
    );
  }
}
