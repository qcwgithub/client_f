import 'dart:io';

import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/network/server.dart';
import 'package:scene_hub/providers/nav_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isWindows) {
      _initChannelUserId();
    }
  }

  void _initChannelUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? last = prefs.getString("channel_user_id");
    if (last != null && mounted) {
      setState(() {
        emailController.text = last;
      });
    }
  }

  void _saveChannelUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("channel_user_id", id);
  }

  final TextEditingController emailController = TextEditingController();
  bool _isLoggingIn = false;
  String? _errorText;

  Future<void> _login(String channelUserId) async {
    Server server = Server.instance;
    if (server.state != NetworkStatus.init) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorText = null;
    });

    server.setIpAndPort("localhost", 8020);
    server.setChannelAndChannelUserId("uuid", channelUserId);

    if (await server.connectAndLoginOnce()) {
      _saveChannelUserId(channelUserId);
      server.startLoop();
    } else {
      setState(() {
        _isLoggingIn = false;
        _errorText = "Login Failed";
      });
    }

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) {
    //       return const HomePage();
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo / Title
            Text(
              "SceneHub",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Join with your email or continue as a guest",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            // Email TextField
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoggingIn
                    ? null
                    : () => _login(emailController.text),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Continue"),
                ),
              ),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            // Guest Mode
            Center(
              child: TextButton(
                onPressed: () {
                  //
                },
                child: const Text("Continue as Guest"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
