import 'dart:math';

List<double> generateWeeklyData() {
  final random = Random();

  return List.generate(7, (index) {
    return random.nextInt(800).toDouble() + 100;
    // generates values between 100 - 900
  });
}