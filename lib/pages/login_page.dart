import 'main_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage>{
  final TextEditingController emailController = TextEditingController();

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
            Text (
              "SceneHub",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              )
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              "Join with your email or continue as a guest",
              style: TextStyle(fontSize: 16, color: Colors.black54)
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
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
                    return const MainPage();
                  }));
                }, 
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Continue"),
                ),
              ),
            ),

            // Guest Mode
            Center(
              child: TextButton(
                onPressed: () {
                  // 
                },
                child: const Text("Continue as Guest")),
            ),
          ],
        ),
      )
    );
  }
}