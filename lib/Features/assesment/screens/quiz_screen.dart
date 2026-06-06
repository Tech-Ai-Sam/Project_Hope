import 'package:flutter/material.dart';
import 'package:project_hope/models/assessment_model.dart';

class AssessmentQuizScreen extends StatefulWidget {
  final AssessmentConfig config;
  const AssessmentQuizScreen({super.key, required this.config});

  @override
  State<AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<AssessmentQuizScreen> {
  int _currentIndex = 0;
  int _cumulativeScore = 0;

  void _handleAnswer(int score) {
    _cumulativeScore += score;

    if (_currentIndex < widget.config.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final summaryMessage = widget.config.resultInterpreter(_cumulativeScore);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[950],
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.analytics_outlined,
              color: widget.config.themeColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Assessment Compiled",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summaryMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.config.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Return to list portal
                },
                child: const Text(
                  "Return to Sanctuary",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.config.questions[_currentIndex];
    final totalQuestions = widget.config.questions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.config.title.toUpperCase(),
          style: const TextStyle(fontSize: 12, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / totalQuestions,
              backgroundColor: Colors.white10,
              color: widget.config.themeColor,
              minHeight: 3,
            ),
            const SizedBox(height: 16),
            Text(
              "Question ${_currentIndex + 1} of $totalQuestions",
              style: TextStyle(
                color: widget.config.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currentQuestion.questionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, idx) {
                  final option = currentQuestion.options[idx];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _handleAnswer(option.score),
                      child: Text(
                        option.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
