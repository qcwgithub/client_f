import 'package:client_f/widgets/scene_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> _fakeScenes = const [
    {
      "title": "I'm at Taylor Swift Concert",
      "subtitle": "Anyone here at gate B?",
    },
    {
      "title": "Coding Flutter in a café",
      "subtitle": "What are you guys building today?",
    },
    {
      "title": "Stuck at airport delay",
      "subtitle": "How long have you waited?",
    },
    {
      "title": "Watching NBA Game",
      "subtitle": "Lakers vs Celtics — who wins?",
    },
    {
      "title": "Learning Japanese",
      "subtitle": "Any good tips?",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenes"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _fakeScenes.length,
        itemBuilder: (context, index) {
          final s = _fakeScenes[index];
          return SceneCard (
            title: s["title"]!,
            subtitle: s["subtitle"]!,
          );
        },
      ),
    );
  }
}