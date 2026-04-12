import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';

class MainHub extends StatefulWidget {
  const MainHub({super.key});

  @override
  State<MainHub> createState() => _MainHubState();
}

class _MainHubState extends State<MainHub> {
  int _selectedIndex = 0;
  int _totalPoints = 1580;

  final List<ExpenseTransaction> _dummyTransactions = [
    ExpenseTransaction(title: 'Starbucks Coffee', amount: 250.0, date: DateTime.now().subtract(const Duration(hours: 2)), category: 'Food & Dining', isExpense: true),
    ExpenseTransaction(title: 'Monthly Salary', amount: 45000.0, date: DateTime.now().subtract(const Duration(days: 1)), category: 'Income', isExpense: false),
    ExpenseTransaction(title: 'Uber Ride', amount: 120.0, date: DateTime.now().subtract(const Duration(hours: 5)), category: 'Transport', isExpense: true),
    ExpenseTransaction(title: 'Amazon Shopping', amount: 1500.0, date: DateTime.now().subtract(const Duration(days: 2)), category: 'Shopping', isExpense: true),
    ExpenseTransaction(title: 'Gym Membership', amount: 2000.0, date: DateTime.now().subtract(const Duration(days: 3)), category: 'Health', isExpense: true),
    ExpenseTransaction(title: 'Netflix Subscription', amount: 499.0, date: DateTime.now().subtract(const Duration(days: 4)), category: 'Entertainment', isExpense: true),
    ExpenseTransaction(title: 'Grocery Store', amount: 3200.0, date: DateTime.now().subtract(const Duration(days: 5)), category: 'Food & Dining', isExpense: true),
    ExpenseTransaction(title: 'Gas Station', amount: 2500.0, date: DateTime.now().subtract(const Duration(days: 6)), category: 'Transport', isExpense: true),
    ExpenseTransaction(title: 'Zomato Delivery', amount: 450.0, date: DateTime.now().subtract(const Duration(days: 7)), category: 'Food & Dining', isExpense: true),
    ExpenseTransaction(title: 'Freelance Project', amount: 12000.0, date: DateTime.now().subtract(const Duration(days: 8)), category: 'Income', isExpense: false),
    ExpenseTransaction(title: 'Internet Bill', amount: 999.0, date: DateTime.now().subtract(const Duration(days: 9)), category: 'Utilities', isExpense: true),
    ExpenseTransaction(title: 'Apple Music', amount: 99.0, date: DateTime.now().subtract(const Duration(days: 10)), category: 'Entertainment', isExpense: true),
    ExpenseTransaction(title: 'Pharmacy', amount: 800.0, date: DateTime.now().subtract(const Duration(days: 11)), category: 'Health', isExpense: true),
    ExpenseTransaction(title: 'Electricity Bill', amount: 4500.0, date: DateTime.now().subtract(const Duration(days: 12)), category: 'Utilities', isExpense: true),
    ExpenseTransaction(title: 'Cinema Tickets', amount: 1200.0, date: DateTime.now().subtract(const Duration(days: 13)), category: 'Entertainment', isExpense: true),
    ExpenseTransaction(title: 'House Rent', amount: 18000.0, date: DateTime.now().subtract(const Duration(days: 14)), category: 'Utilities', isExpense: true),
    ExpenseTransaction(title: 'Book Store', amount: 750.0, date: DateTime.now().subtract(const Duration(days: 15)), category: 'Shopping', isExpense: true),
    ExpenseTransaction(title: 'Dividend Income', amount: 2500.0, date: DateTime.now().subtract(const Duration(days: 16)), category: 'Income', isExpense: false),
    ExpenseTransaction(title: 'Pet Grooming', amount: 1500.0, date: DateTime.now().subtract(const Duration(days: 17)), category: 'Health', isExpense: true),
    ExpenseTransaction(title: 'Flight Ticket', amount: 8500.0, date: DateTime.now().subtract(const Duration(days: 18)), category: 'Transport', isExpense: true),
    ExpenseTransaction(title: 'Clothing Store', amount: 5000.0, date: DateTime.now().subtract(const Duration(days: 19)), category: 'Shopping', isExpense: true),
    ExpenseTransaction(title: 'Bonus Payment', amount: 10000.0, date: DateTime.now().subtract(const Duration(days: 20)), category: 'Income', isExpense: false),
    ExpenseTransaction(title: 'Coffee Beans', amount: 600.0, date: DateTime.now().subtract(const Duration(days: 21)), category: 'Food & Dining', isExpense: true),
    ExpenseTransaction(title: 'Office Lunch', amount: 350.0, date: DateTime.now().subtract(const Duration(days: 22)), category: 'Food & Dining', isExpense: true),
    ExpenseTransaction(title: 'Movie Rental', amount: 150.0, date: DateTime.now().subtract(const Duration(days: 23)), category: 'Entertainment', isExpense: true),
    ExpenseTransaction(title: 'Yoga Class', amount: 500.0, date: DateTime.now().subtract(const Duration(days: 24)), category: 'Health', isExpense: true),
    ExpenseTransaction(title: 'Hardware Store', amount: 2200.0, date: DateTime.now().subtract(const Duration(days: 25)), category: 'Shopping', isExpense: true),
    ExpenseTransaction(title: 'Subscription Box', amount: 1200.0, date: DateTime.now().subtract(const Duration(days: 26)), category: 'Shopping', isExpense: true),
    ExpenseTransaction(title: 'Car Service', amount: 6500.0, date: DateTime.now().subtract(const Duration(days: 27)), category: 'Transport', isExpense: true),
    ExpenseTransaction(title: 'Gift for Friend', amount: 2000.0, date: DateTime.now().subtract(const Duration(days: 28)), category: 'Shopping', isExpense: true),
  ];

  void _addPoints(int points) {
    setState(() {
      _totalPoints += points;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      DashboardScreen(
        transactions: _dummyTransactions,
        statusMessage: "Connected to Firebase",
        onGenerateId: () {},
        totalPoints: _totalPoints,
      ),
      const VaultScreen(),
      FeedScreen(
        currentPoints: _totalPoints,
        onPointsAwarded: _addPoints,
      ),
      const InsightsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006D77),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Vault'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Insights'),
        ],
      ),
    );
  }
}
