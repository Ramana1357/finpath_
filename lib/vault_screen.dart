import 'package:flutter/material.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dream Vault")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _GoalCard(title: "Buy Laptop", progress: 0.6),
          _GoalCard(title: "Trip", progress: 0.3),
          _GoalCard(title: "Emergency Fund", progress: 0.8),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double progress;

  const _GoalCard({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: Colors.teal,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 5),
          Text(
            "${(progress * 100).toInt()}% achieved",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
