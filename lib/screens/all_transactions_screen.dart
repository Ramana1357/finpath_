import 'package:flutter/material.dart';
import '../models/cloud_transaction.dart';
import '../services/cloud_service.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);

  @override
  Widget build(BuildContext context) {
    final cloudService = CloudService();

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CloudTransaction>>(
        stream: cloudService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transactions found.\nRun your Python generator!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Transactions are already sorted by the CloudService logic
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final bool isExpense = tx.isExpense;
              final String sign = isExpense ? '-' : '+';
              final Color amountColor = isExpense ? Colors.redAccent : Colors.green;
              final Color avatarBgColor = isExpense ? (isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1)) : Colors.green.withOpacity(0.1);
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
                      '${tx.date.day}/${tx.date.month}/${tx.date.year} • ${isExpense ? 'Debit' : 'Credit'}',
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
