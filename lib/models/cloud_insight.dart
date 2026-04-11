import 'package:cloud_firestore/cloud_firestore.dart';

class CloudInsight {
  final String userId;
  final int healthScore;
  final List<InsightCategory> topCategories;
  final List<InsightAnomaly> anomalies;
  final List<FeedSummary> feedSummaries; // Added this
  final double physicalCashBalance;
  final DateTime lastUpdated;

  CloudInsight({
    required this.userId,
    required this.healthScore,
    required this.topCategories,
    required this.anomalies,
    required this.feedSummaries,
    required this.physicalCashBalance,
    required this.lastUpdated,
  });

  factory CloudInsight.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CloudInsight(
      userId: data['userId'] ?? '',
      healthScore: data['health_score'] ?? 0,
      topCategories: (data['top_categories'] as List? ?? [])
          .map((c) => InsightCategory.fromMap(c))
          .toList(),
      anomalies: (data['anomalies'] as List? ?? [])
          .map((a) => InsightAnomaly.fromMap(a))
          .toList(),
      feedSummaries: (data['feed_summaries'] as List? ?? [])
          .map((s) => FeedSummary.fromMap(s))
          .toList(),
      physicalCashBalance: (data['physical_cash_balance'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FeedSummary {
  final String type;
  final String title;
  final String message;

  FeedSummary({
    required this.type,
    required this.title,
    required this.message,
  });

  factory FeedSummary.fromMap(Map<String, dynamic> map) {
    return FeedSummary(
      type: map['type'] ?? 'neutral',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
    );
  }
}

class InsightCategory {
  final String category;
  final double amount;
  final double percentage;

  InsightCategory({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory InsightCategory.fromMap(Map<String, dynamic> map) {
    return InsightCategory(
      category: map['category'] ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InsightAnomaly {
  final String title;
  final double amount;
  final String date;

  InsightAnomaly({
    required this.title,
    required this.amount,
    required this.date,
  });

  factory InsightAnomaly.fromMap(Map<String, dynamic> map) {
    return InsightAnomaly(
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] ?? '',
    );
  }
}
