import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../services/finance_feed_service.dart';
import '../presentation/providers/auth_provider.dart';

class DailyQuizCard extends StatefulWidget {
  const DailyQuizCard({super.key});

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  final FinanceFeedService _feedService = FinanceFeedService();
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  late Future<QuizModel?> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = _feedService.getTodaysQuiz();
  }

  Future<void> _handleAnswer(QuizModel quiz, int index) async {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
    });

    final isCorrect = index == quiz.correctIndex;
    final pointsToAward = isCorrect ? quiz.points : 10;

    final authProvider = context.read<AuthProvider>();
    final currentProfile = authProvider.profile;

    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        lifetimePoints: currentProfile.lifetimePoints + pointsToAward,
        lastQuizDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await authProvider.saveProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    
    // Check if already answered today from profile
    final now = DateTime.now();
    bool alreadyDoneToday = false;
    if (profile?.lastQuizDate != null) {
      final lastDate = profile!.lastQuizDate!;
      if (lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day) {
        alreadyDoneToday = true;
      }
    }

    return FutureBuilder<QuizModel?>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        final quiz = snapshot.data;
        if (quiz == null) return const SizedBox.shrink();

        final bool showResults = alreadyDoneToday || _isAnswered;

        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daily FinQuiz",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF006D77),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: showResults ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      showResults ? "Completed" : "+${quiz.points} Pts",
                      style: TextStyle(
                        color: showResults ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                quiz.question,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ...List.generate(quiz.options.length, (index) {
                return _buildOptionButton(quiz, index, showResults);
              }),
              if (showResults) _buildExplanation(quiz),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(QuizModel quiz, int index, bool showResults) {
    bool isSelected = _selectedOptionIndex == index;
    bool isCorrect = index == quiz.correctIndex;
    
    Color backgroundColor = const Color(0xFFEDF6F9);
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black54;

    if (showResults) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showResults ? null : () => _handleAnswer(quiz, index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                quiz.options[index],
                style: TextStyle(
                  color: textColor,
                  fontWeight: (showResults && (isCorrect || isSelected)) 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              if (showResults && (isCorrect || isSelected)) ...[
                const SizedBox(width: 10),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizModel quiz) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF006D77).withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF006D77).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF006D77)),
                SizedBox(width: 5),
                Text(
                  "Did you know?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF006D77),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quiz.explanation,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF006D77)),
      ),
    );
  }
}
