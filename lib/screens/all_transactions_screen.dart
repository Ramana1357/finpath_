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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Local History',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _transactionStream == null
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : StreamBuilder<List<ExpenseTransaction>>(
              stream: _transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: colorScheme.primary));
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      "No local transactions found.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final bool isExpense = tx.isExpense;
                    final String sign = isExpense ? '-' : '+';
                    final Color amountColor =
                        isExpense ? colorScheme.error : colorScheme.primary;
                    final Color avatarBgColor =
                        amountColor.withValues(alpha: 0.1);
                    final IconData txIcon = isExpense
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: avatarBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(txIcon, color: amountColor, size: 22),
                        ),
                        title: Text(
                          tx.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.onSurface),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${tx.date.day} ${_getMonthName(tx.date.month)} • ${tx.category}',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13),
                          ),
                        ),
                        trailing: Text(
                          '$sign ₹${tx.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
