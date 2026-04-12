import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/local_cache_service.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  Stream<List<ExpenseTransaction>>? _transactionStream;

  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);

  @override
  void initState() {
    super.initState();
    // Use the already initialized service from Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cacheService = context.read<LocalCacheService>();
      setState(() {
        _transactionStream = cacheService.watchTransactions();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Local History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _transactionStream == null 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<ExpenseTransaction>>(
        stream: _transactionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No local transactions found.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final bool isExpense = tx.isExpense;
              final String sign = isExpense ? '-' : '+';
              final Color amountColor = isExpense ? Colors.redAccent : Colors.green;
              final Color avatarBgColor = isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);
              final IconData txIcon = isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: avatarBgColor,
                      child: Icon(txIcon, color: amountColor, size: 20)
                  ),
                  title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${tx.date.day}/${tx.date.month}/${tx.date.year} • ${tx.category}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)
                  ),
                  trailing: Text(
                      '$sign ₹${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: amountColor, fontSize: 15)
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
