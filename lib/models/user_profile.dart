class ScoreRecord {
  final DateTime date;
  final double stress;
  final double anxiety;
  final double mood;

  ScoreRecord({
    required this.date,
    required this.stress,
    required this.anxiety,
    required this.mood,
  });
}

// Global list for the prototype
List<ScoreRecord> globalRecords = [
  ScoreRecord(date: DateTime(2026, 4, 1), stress: 5, anxiety: 10, mood: 2),
  ScoreRecord(date: DateTime(2026, 5, 1), stress: 8, anxiety: 6, mood: 12),
  ScoreRecord(date: DateTime(2026, 6, 1), stress: 4, anxiety: 9, mood: 1),
  ScoreRecord(date: DateTime(2026, 7, 1), stress: 7, anxiety: 14, mood: 8),
];