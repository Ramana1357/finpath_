import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const List<String> _tips = [
    "Save 20% of your income",
    "Track your daily expenses",
    "Avoid unnecessary subscriptions",
    "Invest early for growth",
    "Build an emergency fund",
    "Compare prices before buying",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finance Feed")),
      body: ListView.builder(
        itemCount: _tips.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.lightbulb_outline, color: Colors.white),
              ),
              title: Text(
                _tips[index],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Future: Show tip details
              },
            ),
          );
        },
      ),
    );
  }
}
