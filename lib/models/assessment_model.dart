import 'package:flutter/material.dart';

class AssessmentQuestion {
  final String questionText;
  final List<AssessmentOption> options;

  AssessmentQuestion({required this.questionText, required this.options});
}

class AssessmentOption {
  final String text;
  final int score;

  AssessmentOption({required this.text, required this.score});
}

class AssessmentConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final List<AssessmentQuestion> questions;
  final String Function(int totalScore) resultInterpreter;

  AssessmentConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.questions,
    required this.resultInterpreter,
  });
}
