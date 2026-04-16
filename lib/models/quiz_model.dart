class QuizModel {
  final String dateString;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;

  QuizModel({
    required this.dateString,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      dateString: map['date_string'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correct_index'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      points: map['points'] as int? ?? 50,
    );
  }
}
