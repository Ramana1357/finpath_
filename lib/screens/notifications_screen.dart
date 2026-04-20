import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_cache_service.dart';
import '../data/models/vault_model.dart';
import '../models/transaction.dart';
import '../presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime date;
  final bool isCritical;

  NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.date,
    this.isCritical = false,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);

  @override
  Widget build(BuildContext context) {
    final cacheService = context.read<LocalCacheService>();
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ExpenseTransaction>>(
        stream: cacheService.watchTransactions(),
        builder: (context, txSnapshot) {
          return StreamBuilder<List<VaultModel>>(
            stream: cacheService.watchVaults(),
            builder: (context, vaultSnapshot) {
              if (txSnapshot.connectionState == ConnectionState.waiting || vaultSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryTeal));
              }

              final transactions = txSnapshot.data ?? [];
              final vaults = vaultSnapshot.data ?? [];
              final List<NotificationItem> notifications = [];

              // 1. Check Spending Limits
              if (profile != null) {
                final now = DateTime.now();
                
                // Daily Check
                double dailySpent = 0;
                for (var tx in transactions) {
                  if (tx.isExpense && tx.date.day == now.day && tx.date.month == now.month && tx.date.year == now.year) {
                    dailySpent += tx.amount;
                  }
                }
                if (dailySpent > profile.dailyLimit) {
                  notifications.add(NotificationItem(
                    title: "Daily Limit Exceeded!",
                    message: "You've spent ₹${dailySpent.toStringAsFixed(0)}, which is ₹${(dailySpent - profile.dailyLimit).toStringAsFixed(0)} over your daily limit.",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    date: now,
                    isCritical: true,
                  ));
                }

                // Monthly Check
                double monthlySpent = 0;
                for (var tx in transactions) {
                  if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
                    monthlySpent += tx.amount;
                  }
                }
                if (monthlySpent > profile.monthlyLimit) {
                  notifications.add(NotificationItem(
                    title: "Monthly Budget Alert!",
                    message: "Total spending this month is ₹${monthlySpent.toStringAsFixed(0)}. You've exceeded your ₹${profile.monthlyLimit.toStringAsFixed(0)} budget.",
                    icon: Icons.error_outline,
                    color: Colors.redAccent,
                    date: now,
                    isCritical: true,
                  ));
                }
              }

              // 2. Check Completed Vaults
              for (var vault in vaults) {
                if (vault.currentAmount >= vault.targetAmount && vault.targetAmount > 0) {
                  notifications.add(NotificationItem(
                    title: "Goal Reached: ${vault.title}",
                    message: "Congratulations! You've saved 100% of your target (₹${vault.currentAmount.toStringAsFixed(0)}).",
                    icon: Icons.celebration,
                    color: primaryTeal,
                    date: vault.updatedAt,
                  ));
                }
              }

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "No new notifications",
                        style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              // Sort by critical first, then by date
              notifications.sort((a, b) {
                if (a.isCritical != b.isCritical) return a.isCritical ? -1 : 1;
                return b.date.compareTo(a.date);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: item.isCritical ? BorderSide(color: item.color.withOpacity(0.5), width: 1) : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.color.withOpacity(0.1),
                        child: Icon(item.icon, color: item.color),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.bold, color: item.isCritical ? item.color : Colors.black87),
                      ),
                      subtitle: Text(
                        item.message,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Text(
                        DateFormat('MMM d').format(item.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
