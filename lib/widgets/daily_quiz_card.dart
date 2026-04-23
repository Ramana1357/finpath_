import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  bool _isQuizLocked = false;
  int? _activeSessionSelectedIndex;
  late Future<QuizModel?> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = _feedService.getTodaysQuiz();
  }

  Future<void> _handleAnswer(QuizModel quiz, int index) async {
    if (_isQuizLocked) return;

    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final authProvider = context.read<AuthProvider>();
    final currentProfile = authProvider.profile;

    // SECURITY LOCK: Final check against cloud date
    if (currentProfile?.lastQuizDate == todayDate) {
      setState(() => _isQuizLocked = true);
      return;
    }

    setState(() {
      _activeSessionSelectedIndex = index;
      _isQuizLocked = true;
    });

    final isCorrect = index == quiz.correctIndex;
    final pointsToAward = isCorrect ? quiz.points : 10;

    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        lifetimePoints: currentProfile.lifetimePoints + pointsToAward,
        lastQuizDate: todayDate,
        updatedAt: DateTime.now(),
      );
      // PERSIST: This saves to both Cloud (Firestore) and Local (Isar)
      await authProvider.saveProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;
    
    // THE LOCK: Calculate exactly once per build cycle
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final bool isActuallyLocked = _isQuizLocked || (profile?.lastQuizDate == todayDate);

    return FutureBuilder<QuizModel?>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        final quiz = snapshot.data;
        if (quiz == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isActuallyLocked, quiz.points),
              const SizedBox(height: 15),
              Text(
                quiz.question,
                style: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),
              ...List.generate(quiz.options.length, (index) {
                return _buildFreshOptionButton(quiz, index, isActuallyLocked);
              }),
              if (isActuallyLocked) _buildFreshExplanation(quiz.explanation),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isLocked, int points) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Daily FinQuiz",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.primary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLocked ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            isLocked ? "Completed" : "+$points Pts",
            style: TextStyle(
              color: isLocked ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreshOptionButton(QuizModel quiz, int index, bool isLocked) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isCorrectIndex = index == quiz.correctIndex;
    
    // DEFAULT STATE (Neutral)
    Color backgroundColor = colorScheme.background;
    Color borderColor = Colors.transparent;
    Color textColor = colorScheme.onSurface.withValues(alpha: 0.7);

    if (isLocked) {
      if (isCorrectIndex) {
        // UNIVERSAL SUCCESS THEME: Green for correct answer
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (index == _activeSessionSelectedIndex) {
        // ACTIVE SESSION ONLY: Red for user error
        backgroundColor = colorScheme.error.withValues(alpha: 0.1);
        borderColor = colorScheme.error;
        textColor = colorScheme.error;
      } else {
        // DISABLED STATE: Grey for others
        backgroundColor = colorScheme.onSurface.withValues(alpha: 0.05);
        textColor = colorScheme.onSurface.withValues(alpha: 0.3);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isLocked ? null : () => _handleAnswer(quiz, index),
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
              Expanded( // LAYOUT SAFETY: Expansion constraint
                child: Text(
                  quiz.options[index],
                  textAlign: TextAlign.center,
                  softWrap: true, // LAYOUT SAFETY
                  maxLines: 3,    // LAYOUT SAFETY
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isLocked && isCorrectIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isLocked && (isCorrectIndex || index == _activeSessionSelectedIndex)) ...[
                const SizedBox(width: 10),
                Icon(
                  isCorrectIndex ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isCorrectIndex ? Colors.green : colorScheme.error,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreshExplanation(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 5),
                Text(
                  "FinTips Explanation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }
}
