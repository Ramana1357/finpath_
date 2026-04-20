class FinanceTipModel {
  final String id;
  final String type;
  final String title;
  final String source;
  final String content;
  final String imageUrl;
  final DateTime timestamp;

  FinanceTipModel({
    required this.id,
    required this.type,
    required this.title,
    required this.source,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
  });

  factory FinanceTipModel.fromMap(String id, Map<String, dynamic> map) {
    return FinanceTipModel(
      id: id,
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      source: map['source'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imageUrl: (map['image_url'] ?? map['imageUrl']) as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as int? ?? 0) * 1000,
      ),
    );
  }
}
