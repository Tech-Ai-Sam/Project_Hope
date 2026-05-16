import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// For kPrimaryAccent

// Clean Data Model
class ScoreRecord {
  final double stress;
  final double anxiety;
  final double mood;
  ScoreRecord({
    required this.stress,
    required this.anxiety,
    required this.mood,
  });
}

// Global dummy data
List<ScoreRecord> globalRecords = [
  ScoreRecord(stress: 5, anxiety: 8, mood: 10),
  ScoreRecord(stress: 7, anxiety: 10, mood: 5),
  ScoreRecord(stress: 4, anxiety: 6, mood: 12),
  ScoreRecord(stress: 8, anxiety: 12, mood: 7),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("YOUR PROGRESS"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStackedBarChart(),
            const SizedBox(height: 30),
            _buildSummaryCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedBarChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 35,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(
                  "${value.toInt()}",
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Apr', 'May', 'Jun', 'Jul'];
                  if (value.toInt() >= months.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ), // FIXED: Corrected EdgeInsets
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: globalRecords.asMap().entries.map((e) {
            final record = e.value;
            final double total = record.stress + record.anxiety + record.mood;

            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: total,
                  width: 20,
                  color: Colors.transparent, // Required when using stackItems
                  borderRadius: BorderRadius.circular(6),
                  rodStackItems: [
                    // FIXED: Using BarChartRodStackItem instead of BarStackItem
                    BarChartRodStackItem(
                      0,
                      record.stress,
                      const Color(0xFF1B4332),
                    ),
                    BarChartRodStackItem(
                      record.stress,
                      record.stress + record.anxiety,
                      const Color(0xFF2D6A4F),
                    ),
                    BarChartRodStackItem(
                      record.stress + record.anxiety,
                      total,
                      const Color(0xFF52B788),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final last = globalRecords.last;
    return Row(
      children: [
        _statTile(
          "Current Stress",
          "${last.stress.toInt()}",
          const Color(0xFF52B788),
        ),
        const SizedBox(width: 15),
        _statTile("Mood Level", "Stable", Colors.white70),
      ],
    );
  }

  Widget _statTile(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 5),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
