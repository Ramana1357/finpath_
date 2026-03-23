import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'utils/random_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<double> weeklyData;

  @override
  void initState() {
    super.initState();
    weeklyData = generateWeeklyData(); // 🔥 random data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔝 HEADER
            const Text("FINPATH",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // 🔷 TOP CARDS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _topCard("FinPoints", "1580", Icons.star),
                _topCard("Today", "₹320", Icons.today),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 SWIPE CHART
            SizedBox(
              height: 250,
              child: PageView(
                children: [
                  _monthlyChart(),
                  _weeklyChart(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TOTAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text("Total Spending"),
                  Text("₹5320",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Top Card
  Widget _topCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // 🔵 Monthly Chart (Dummy)
  Widget _monthlyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Monthly Overview"),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(sections: [
                PieChartSectionData(value: 40, color: Colors.teal, title: ''),
                PieChartSectionData(value: 30, color: Colors.green, title: ''),
                PieChartSectionData(value: 20, color: Colors.orange, title: ''),
                PieChartSectionData(value: 10, color: Colors.blue, title: ''),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Weekly Chart (REAL RANDOM DATA)
  Widget _weeklyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Weekly Expenses"),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyData[i],
                        color: Colors.teal,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
