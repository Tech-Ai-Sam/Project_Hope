// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project_hope/main.dart';
import 'package:project_hope/services/ai_service.dart'; // Handles kPrimaryAccent

class DiagnosticHub extends StatelessWidget {
  const DiagnosticHub({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Standard Clinical Frequency Options (GAD/PHQ) ---
    final List<Map<String, dynamic>> frequencyOptions = [
      {"label": "Not at all", "value": 0},
      {"label": "Several days", "value": 1},
      {"label": "More than half the days", "value": 2},
      {"label": "Nearly every day", "value": 3},
    ];

    // --- Dynamic Psychometric Intensity/Agreement Options (Burnout/CSI) ---
    final List<Map<String, dynamic>> agreementOptions = [
      {"label": "Strongly disagree", "value": 0},
      {"label": "Disagree", "value": 1},
      {"label": "Agree", "value": 2},
      {"label": "Strongly agree", "value": 3},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "DIAGNOSTIC HUB",
              style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "CLINICAL ASSESSMENT PROTOCOLS",
              style: TextStyle(
                color: kPrimaryAccent.withOpacity(0.4),
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        children: [
          // --- MODE 1: GAD-7 ---
          _buildAssessmentTile(
            context,
            title: "Anxiety Screen (GAD-7)",
            description:
                "Standard clinical assessment for identifying persistent worry, somatic tension, and hyperarousal patterns over the last two weeks.",
            scoringOptions: frequencyOptions,
            questions: [
              "Feeling nervous, anxious, or on edge?",
              "Not being able to stop or control worrying?",
              "Worrying too much about many different things?",
              "Trouble relaxing?",
              "Being so restless that it is hard to sit still?",
              "Becoming easily annoyed or irritable?",
              "Feeling afraid, as if something awful might happen?",
            ],
          ),
          const SizedBox(height: 18),

          // --- MODE 2: PHQ-2 ---
          _buildAssessmentTile(
            context,
            title: "Mood Screener (PHQ-2)",
            description:
                "Initial rapid diagnostic evaluation measuring core frequency of depressed mood, anhedonia, and situational loss of interest.",
            scoringOptions: frequencyOptions,
            questions: [
              "Little interest or pleasure in doing things?",
              "Feeling down, depressed, or hopeless?",
            ],
          ),
          const SizedBox(height: 18),

          // --- MODE 3: PHQ-9 FULL DEPRESSION PANEL ---
          _buildAssessmentTile(
            context,
            title: "Depression Panel (PHQ-9)",
            description:
                "Complete diagnostic tracking tool evaluating severity levels of depression, sleep disruption, psychomotor changes, and systemic lethargy.",
            scoringOptions: frequencyOptions,
            questions: [
              "Little interest or pleasure in doing things?",
              "Feeling down, depressed, or hopeless?",
              "Trouble falling or staying asleep, or sleeping too much?",
              "Feeling tired or having little energy?",
              "Poor appetite or overeating?",
              "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?",
              "Trouble concentrating on things, such as reading the newspaper or watching television?",
              "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?",
              "Thoughts that you would be better off dead, or of hurting yourself in some way?",
            ],
          ),
          const SizedBox(height: 18),

          // --- MODE 4: CSI-4 BURNOUT & STRESS INDEX ---
          _buildAssessmentTile(
            context,
            title: "Stress & Burnout Index (CSI-4)",
            description:
                "Calculates systemic neurological burnout limits, chronic occupational exhaustion, and persistent task-induced fatigue metrics.",
            scoringOptions: agreementOptions,
            questions: [
              "Feeling emotionally drained or exhausted by your daily routines?",
              "Finding it increasingly difficult to concentrate or remain focused on complex tasks?",
              "Experiencing physical tension, stress-induced headaches, or unrefreshing sleep cycles?",
              "Feeling increasingly detached, cynical, or unaccomplished regarding your personal or professional progress?",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTile(
    BuildContext context, {
    required String title,
    required String description,
    required List<Map<String, dynamic>> scoringOptions,
    required List<String> questions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.all(24),
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
          trailing: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 12,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssessmentEngine(
                  assessmentTitle: title,
                  questions: questions,
                  scoringOptions: scoringOptions,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CORE ASSESSMENT ENGINE (With Dynamic Risk Elevation Actions)
// ============================================================================
class AssessmentEngine extends StatefulWidget {
  final String assessmentTitle;
  final List<String> questions;
  final List<Map<String, dynamic>> scoringOptions;

  const AssessmentEngine({
    super.key,
    required this.assessmentTitle,
    required this.questions,
    required this.scoringOptions,
  });

  @override
  State<AssessmentEngine> createState() => _AssessmentEngineState();
}

class _AssessmentEngineState extends State<AssessmentEngine> {
  int _currentIndex = 0;
  int _runningScore = 0;

  void _processAnswer(int points) {
    _runningScore += points;

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _evaluateFinalMetrics();
    }
  }

  // --- Clinical Interpretation Engine (Calculates Severity & AI Hand-off State) ---
  Map<String, dynamic> _interpretScore(String title, int score) {
    String cleanTitle = title.toLowerCase();

    if (cleanTitle.contains("gad-7")) {
      if (score <= 4) {
        return {
          "status": "MINIMAL ANXIETY",
          "action": "Continue baseline wellness tracking.",
          "isElevated": false,
        };
      }
      if (score <= 9) {
        return {
          "status": "MILD ANXIETY",
          "action": "Monitor symptoms; consider mindfulness protocols.",
          "isElevated": false,
        };
      }
      if (score <= 14) {
        return {
          "status": "MODERATE ANXIETY",
          "action": "Clinical consultation is recommended.",
          "isElevated": true,
        };
      }
      return {
        "status": "SEVERE ANXIETY",
        "action": "Immediate clinical evaluation is highly advised.",
        "isElevated": true,
      };
    }

    if (cleanTitle.contains("phq-2")) {
      if (score >= 3) {
        return {
          "status": "POSITIVE SCREEN (HIGH RISK)",
          "action": "Further full-panel clinical screening recommended.",
          "isElevated": true,
        };
      }
      return {
        "status": "NEGATIVE SCREEN (LOW RISK)",
        "action": "No active mood interventions indicated.",
        "isElevated": false,
      };
    }

    if (cleanTitle.contains("phq-9")) {
      if (score <= 4) {
        return {
          "status": "MINIMAL DEPRESSION",
          "action": "Maintain typical lifestyle configurations.",
          "isElevated": false,
        };
      }
      if (score <= 9) {
        return {
          "status": "MILD DEPRESSION",
          "action": "Incorporate active recovery and check-ins.",
          "isElevated": false,
        };
      }
      if (score <= 14) {
        return {
          "status": "MODERATE DEPRESSION",
          "action": "Therapeutic consultation is advised.",
          "isElevated": true,
        };
      }
      if (score <= 19) {
        return {
          "status": "MODERATELY SEVERE DEPRESSION",
          "action": "Medical and clinical review recommended.",
          "isElevated": true,
        };
      }
      return {
        "status": "SEVERE DEPRESSION",
        "action": "Urgent expert diagnostic evaluation needed.",
        "isElevated": true,
      };
    }

    if (cleanTitle.contains("csi-4")) {
      if (score <= 3) {
        return {
          "status": "OPTIMAL RESILIENCE",
          "action":
              "System operating smoothly within stress threshold parameters.",
          "isElevated": false,
        };
      }
      if (score <= 7) {
        return {
          "status": "MODERATE BURNOUT RISK",
          "action": "Prioritize downtime; adjust immediate workloads.",
          "isElevated": false,
        };
      }
      return {
        "status": "CRITICAL EXHAUSTION",
        "action":
            "High risk of systematic burnout. De-escalate tasks immediately.",
        "isElevated": true,
      };
    }

    return {
      "status": "EVALUATION COMPLETE",
      "action": "Data compiled successfully.",
      "isElevated": false,
    };
  }

  void _evaluateFinalMetrics() {
    final diagnosticInfo = _interpretScore(
      widget.assessmentTitle,
      _runningScore,
    );
    final bool isElevated = diagnosticInfo["isElevated"] as bool;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF09090A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.03), width: 1),
        ),
        title: const Text(
          "ASSESSMENT DIAGNOSTIC",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              diagnosticInfo["status"]!.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isElevated ? Colors.redAccent : kPrimaryAccent,
                fontSize: 18,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              diagnosticInfo["action"]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Your Metrics Index Score is: $_runningScore",
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        actions: [
          Row(
            children: [
              // Primary Dismiss Button
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to Hub
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.white.withOpacity(0.04),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: const Text(
                    "OKAY",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Conditional AI Hand-off Button
              if (isElevated) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to Hub

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            initialContext:
                                "User has an elevated score of $_runningScore on ${widget.assessmentTitle}. Initiate supportive conversation and provide resources.",
                          ),
                        ),
                      );
                      debugPrint(
                        "Navigating to Hope AI chat session with score: $_runningScore",
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: kPrimaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "TALK TO HOPE AI",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.assessmentTitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            size: 20,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: kPrimaryAccent,
                minHeight: 2,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              "NODE EVALUATION TRACKER // CORE NODE ${_currentIndex + 1} OF ${widget.questions.length}",
              style: TextStyle(
                color: kPrimaryAccent.withOpacity(0.4),
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.questions[_currentIndex],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const Spacer(),
            ...widget.scoringOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09090A),
                    foregroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.03),
                        width: 1,
                      ),
                    ),
                  ),
                  onPressed: () => _processAnswer(option['value']),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option['label'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.1),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
