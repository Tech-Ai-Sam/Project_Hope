import 'package:flutter/material.dart';
import 'package:project_hope/models/assessment_model.dart'; // Updated import path

final List<AssessmentOption> standardFourOptions = [
  AssessmentOption(text: "Not at all", score: 0),
  AssessmentOption(text: "Several days", score: 1),
  AssessmentOption(text: "More than half the days", score: 2),
  AssessmentOption(text: "Nearly every day", score: 3),
];

final List<AssessmentConfig> appAssessments = [
  // --- PHQ-9 DEPRESSION SCREENER ---
  AssessmentConfig(
    title: "Well-being Index (PHQ-9)",
    subtitle:
        "Evaluate mood, energy, and concentration levels over the past 2 weeks.",
    icon: Icons.wb_sunny_outlined,
    themeColor: Colors.teal,
    questions: [
      AssessmentQuestion(
        questionText: "Little interest or pleasure in doing things?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Feeling down, depressed, or hopeless?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText:
            "Trouble falling or staying asleep, or sleeping too much?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Feeling tired or having little energy?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Poor appetite or overeating?",
        options: standardFourOptions,
      ),
    ],
    resultInterpreter: (score) {
      if (score <= 4) {
        return "Minimal or no distress. Keep maintaining your routine!";
      }
      if (score <= 9) {
        return "Mild variation detected. Prioritize self-care and rest.";
      }
      return "Moderate to high variation. Consider chatting with a supportive person or counselor.";
    },
  ),

  // --- GAD-7 ANXIETY SCREENER ---
  AssessmentConfig(
    title: "Calmness Assessment (GAD-7)",
    subtitle: "Track physical restlessness, worry, and tension.",
    icon: Icons.shield_moon_outlined,
    themeColor: Colors.indigo,
    questions: [
      AssessmentQuestion(
        questionText: "Feeling nervous, anxious, or on edge?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Not being able to stop or control worrying?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Worrying too much about different things?",
        options: standardFourOptions,
      ),
      AssessmentQuestion(
        questionText: "Trouble relaxing?",
        options: standardFourOptions,
      ),
    ],
    resultInterpreter: (score) {
      if (score <= 4) return "Your baseline is calm and centered.";
      if (score <= 9) {
        return "Mild tension noticed. Deep breathing exercises could offer immediate relief.";
      }
      return "Elevated stress detected. This is a good time to slow down and practice mindfulness grounding.";
    },
  ),
];
