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

  @override
  Widget build(BuildContext context) {
    final cacheService = context.read<LocalCacheService>();
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: StreamBuilder<List<ExpenseTransaction>>(
        stream: cacheService.watchTransactions(),
        builder: (context, txSnapshot) {
          return StreamBuilder<List<VaultModel>>(
            stream: cacheService.watchVaults(),
            builder: (context, vaultSnapshot) {
              if (txSnapshot.connectionState == ConnectionState.waiting ||
                  vaultSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary));
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
                  if (tx.isExpense &&
                      tx.date.day == now.day &&
                      tx.date.month == now.month &&
                      tx.date.year == now.year) {
                    dailySpent += tx.amount;
                  }
                }
                if (dailySpent > profile.dailyLimit) {
                  notifications.add(NotificationItem(
                    title: "Daily Limit Exceeded!",
                    message:
                        "You've spent ₹${dailySpent.toStringAsFixed(0)}, which is ₹${(dailySpent - profile.dailyLimit).toStringAsFixed(0)} over your daily limit.",
                    icon: Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    date: now,
                    isCritical: true,
                  ));
                }

                // Monthly Check
                double monthlySpent = 0;
                for (var tx in transactions) {
                  if (tx.isExpense &&
                      tx.date.month == now.month &&
                      tx.date.year == now.year) {
                    monthlySpent += tx.amount;
                  }
                }
                if (monthlySpent > profile.monthlyLimit) {
                  notifications.add(NotificationItem(
                    title: "Monthly Budget Alert!",
                    message:
                        "Total spending this month is ₹${monthlySpent.toStringAsFixed(0)}. You've exceeded your ₹${profile.monthlyLimit.toStringAsFixed(0)} budget.",
                    icon: Icons.error_outline,
                    color: colorScheme.error,
                    date: now,
                    isCritical: true,
                  ));
                }
              }

              // 2. Check Completed Vaults
              for (var vault in vaults) {
                if (vault.currentAmount >= vault.targetAmount &&
                    vault.targetAmount > 0) {
                  notifications.add(NotificationItem(
                    title: "Goal Reached: ${vault.title}",
                    message:
                        "Congratulations! You've saved 100% of your target (₹${vault.currentAmount.toStringAsFixed(0)}).",
                    icon: Icons.celebration,
                    color: colorScheme.primary,
                    date: vault.updatedAt,
                  ));
                }
              }

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        "No new notifications",
                        style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
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
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: item.isCritical
                          ? BorderSide(
                              color: item.color.withValues(alpha: 0.5), width: 1)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.color.withValues(alpha: 0.1),
                        child: Icon(item.icon, color: item.color),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isCritical
                                ? item.color
                                : colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        item.message,
                        style: TextStyle(
                            fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: Text(
                        DateFormat('MMM d').format(item.date),
                        style: TextStyle(
                            color: colorScheme.outline, fontSize: 11),
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

