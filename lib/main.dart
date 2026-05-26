import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_hope/services/ai_service.dart';
import 'package:project_hope/view/mainscreen.dart';

// ==========================================
// 1. INITIALIZATION & THEME
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't put heavy logic here!
  runApp(const ProjectHope());
}

List<double> globalRecentScores = [5, 8, 4];

const Color kBackgroundColor = Color(0xFF1A1B25);
const Color kPrimaryAccent = Color(0xFF6200EE);

class ProjectHope extends StatelessWidget {
  const ProjectHope({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          elevation: 0,
        ),
      ),
    );
  }
}

// ==========================================
// 2. NAVIGATION BAR LOGIC
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Mainscreen(), // Index 0: Home (This was missing!)
    const MusicScreen(), // Index 1: Ambient
    const ProfileScreen(), // Index 2: Profile
    const SettingsScreen(), // Index 3: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kBackgroundColor,
        selectedItemColor: kPrimaryAccent,
        unselectedItemColor: Colors.white38,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: "Ambient",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. ASSESSMENT ENGINE
// ==========================================
class AssessmentScreen extends StatefulWidget {
  final String title;
  final List<String> questions;
  final Map<int, String> severityThresholds;
  final String testType;

  const AssessmentScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.severityThresholds,
    required this.testType,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _totalScore = 0;
  int _currentIdx = 0;
  final List<int> _scoreHistory = [];

  final List<Map<String, dynamic>> _options = [
    {"text": "Never", "score": 0},
    {"text": "Rarely", "score": 1},
    {"text": "Sometimes", "score": 2},
    {"text": "Frequently", "score": 3},
    {"text": "Often", "score": 4},
    {"text": "Always", "score": 5},
  ];

  // Logic to handle answer selection
  void _submitScore(int points) {
    setState(() {
      _scoreHistory.add(points);
      _totalScore += points;

      if (_currentIdx < widget.questions.length - 1) {
        _currentIdx++;
      } else {
        _showResults();
      }
    });
  }

  // Logic for the back button
  void _goBack() {
    if (_currentIdx > 0) {
      setState(() {
        int lastScore = _scoreHistory.removeLast();
        _totalScore -= lastScore;
        _currentIdx--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showResults() {
    setState(() {
      globalRecentScores.add(_totalScore.toDouble());
    });
    String severity = "Normal";
    var sortedKeys = widget.severityThresholds.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (var threshold in sortedKeys) {
      if (_totalScore >= threshold) {
        severity = widget.severityThresholds[threshold]!;
        break;
      }
    }
    setState(() {
      // Add the new score to our global list
      globalRecentScores.add(_totalScore.toDouble());

      // Optional: Keep only the last 7-10 scores so the graph doesn't get too crowded
      if (globalRecentScores.length > 10) {
        globalRecentScores.removeAt(0);
      }
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        title: Text("$severity ${widget.title}"),
        content: Text(
          "Your ${widget.testType} score is $_totalScore.\n\nWould you like to talk to Hope?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Closes the Dialog
              Navigator.pop(
                context,
              ); // Closes the Assessment Screen (goes back to Hub)
            },
            child: const Text(
              "Maybe Later",
              style: TextStyle(color: Colors.white38),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryAccent),
            onPressed: () {
              Navigator.pop(context); // Closes the Dialog
              // pushReplacement ensures the user can't "back" into the completed test
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(score: _totalScore),
                ),
              );
            },
            child: const Text(
              "TALK TO HOPE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _goBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Step ${_currentIdx + 1} of ${widget.questions.length}",
              style: const TextStyle(color: Colors.white30),
            ),
            const SizedBox(height: 20),
            Text(
              widget.questions[_currentIdx],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ..._options.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => _submitScore(opt['score']),
                  child: Text(
                    opt['text'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3a. DIAGNOSTIC HUB (RE-CALIBRATED)
// ==========================================
class DiagnosticHub extends StatelessWidget {
  const DiagnosticHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CHOOSE ASSESSMENT")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. GAD-7 (7 Questions | Max Score: 35)
          _buildTestTile(
            context,
            "Anxiety Scan (GAD-7)",
            "Assessment for persistent worry and tension.",
            [
              "Do you feel nervous, anxious, or on edge?",
              "Are you unable to stop or control your worrying?",
              "Do you worry too much about many different things?",
              "Is it difficult for you to relax?",
              "Do you feel so restless that it's hard to sit still?",
              "Do you become easily annoyed or irritable?",
              "Do you feel afraid, as if something awful might happen?",
            ],

            {25: "Severe", 18: "Moderate", 8: "Mild", 0: "Normal"},
            "GAD-7",
          ),
          const SizedBox(height: 15),

          // 2. PHQ-2 (2 Questions | Max Score: 10)
          _buildTestTile(
            context,
            "Depression Screener (PHQ-2)",
            "Quick check for mood and interest levels.",
            [
              "Do you have little interest or pleasure in doing things?",
              "Do you feel down, depressed, or hopeless?",
            ],
            // Calibration: 6+ is High Probability (Since max is 10)
            {6: "High Probability", 3: "Low Probability", 0: "Normal"},
            "PHQ-2",
          ),
          const SizedBox(height: 15),

          // 3. PC-PTSD-5 (5 Questions | Max Score: 25)
          _buildTestTile(
            context,
            "PTSD Screener (PC-PTSD-5)",
            "Check for the impact of traumatic events.",
            [
              "Do you have nightmares about a stressful event?",
              "Do you try hard not to think about it or avoid reminders?",
              "Do you feel constantly on guard or get startled easily?",
              "Do you feel numb or detached from your surroundings?",
              "Do you feel guilty or unable to stop blaming yourself?",
            ],
            // Calibration: 15+ is High Probability
            {15: "High Probability", 8: "Moderate Probability", 0: "Normal"},
            "PC-PTSD-5",
          ),
        ],
      ),
    );
  }
}

Widget _buildTestTile(
  BuildContext context,
  String title,
  String desc,
  List<String> qs,
  Map<int, String> thresholds,
  String type,
) {
  return Card(
    color: Colors.white10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(20),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(desc, style: const TextStyle(color: Colors.white38)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentScreen(
            title: title,
            questions: qs,
            severityThresholds: thresholds,
            testType: type,
          ),
        ),
      ),
    ),
  );
}

// ==========================================
// 5. AMBIENT MUSIC SCREEN
// ==========================================
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  String? _currentlyPlaying;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;

  final List<Map<String, String>> _ambientTracks = [
    {
      "title": "Deep Focus",
      "sub": "Lo-fi Studio Beats",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "icon": "wb_sunny_outlined",
    },
    {
      "title": "Rainy Kochi",
      "sub": "Soft Rain & Thunder",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
      "icon": "umbrella",
    },
    {
      "title": "Theta Waves",
      "sub": "432Hz Meditation",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3",
      "icon": "waves",
    },
    {
      "title": "Deep Sleep (Delta)",
      "sub": "2Hz - Pure Healing Waves",
      "url":
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", // Replace with actual Delta MP3
      "icon": "bedtime",
    },
    {
      "title": "Focus Flow (Alpha)",
      "sub": "10Hz - Enhances Concentration",
      "url":
          "https://youtu.be/RxhrYToJZuo?si=lZmpzPtVqsacM5Qt", // Replace with actual Alpha MP3
      "icon": "psychology",
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handlePlayback(String title, String url) async {
    try {
      setState(() => _isLoadingAudio = true);
      if (_currentlyPlaying == title && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentlyPlaying != title) await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        setState(() => _currentlyPlaying = title);
      }
      await _audioPlayer.setBalance(0.0);
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AMBIENT SPACE")),
      body: Column(
        children: [
          // 1. The Loading Indicator stays at the very top of the body
          if (_isLoadingAudio)
            const LinearProgressIndicator(
              color: kPrimaryAccent,
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
          if (_currentlyPlaying != null &&
              (_currentlyPlaying!.contains("Delta") ||
                  _currentlyPlaying!.contains("Alpha")))
            Container(
              width: double.infinity,
              color: Colors.amber.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: const Row(
                children: [
                  Icon(Icons.headphones, size: 16, color: Colors.amber),
                  SizedBox(width: 10),
                  Text(
                    "Binaural active: Use headphones for full effect",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // 2. We use Expanded so the ListView takes up the remaining space
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _ambientTracks.length,
              itemBuilder: (context, index) {
                final track = _ambientTracks[index];
                bool isPlayingThis =
                    _currentlyPlaying == track['title'] && _isPlaying;
                return Card(
                  // Fixed the opacity deprecation here too
                  color: isPlayingThis
                      ? kPrimaryAccent.withValues(alpha: 0.1)
                      : Colors.white10,
                  child: ListTile(
                    leading: Icon(_getIconData(track['icon']!)),
                    title: Text(track['title']!),
                    subtitle: Text(track['sub']!),
                    trailing: IconButton(
                      icon: Icon(
                        isPlayingThis ? Icons.pause_circle : Icons.play_circle,
                        size: 40,
                      ),
                      onPressed: () =>
                          _handlePlayback(track['title']!, track['url']!),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_currentlyPlaying != null)
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.black26,
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq, color: kPrimaryAccent, size: 18),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Playing: $_currentlyPlaying",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'umbrella':
        return Icons.umbrella;
      case 'waves':
        return Icons.waves;
      case 'bedtime':
        return Icons.bedtime;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

// ==========================================
// 6. PROFILE SECTION
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Data for the graph - eventually this moves to a database
  final List<double> recentScores = const [5, 8, 4, 12, 7, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YOUR PROGRESS")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assessment History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // --- THE GRAPH CARD ---
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: recentScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: kPrimaryAccent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: kPrimaryAccent.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                _buildStatCard(
                  "Last Score",
                  "${recentScores.last}",
                  Colors.blueAccent,
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Status",
                  _getStatus(recentScores.last),
                  Colors.cyanAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
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

  String _getStatus(double score) {
    if (score < 5) return "Low";
    if (score < 10) return "Moderate";
    return "High";
  }
}

// ==============================================
// 7. SETTINGS SECTION
// ==========================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SETTINGS")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: kPrimaryAccent),
            title: const Text("Account"),
            subtitle: const Text("Firebase Sync coming soon"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account features are under development!"),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_none,
              color: kPrimaryAccent,
            ),
            title: const Text("Reminders"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Reminder feature is under development!"),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white38),
            title: const Text("About Project HOPE"),
            subtitle: const Text("Tech AI Inc. Prototype v2.5.48"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Project HOPE",
                applicationVersion: "v2.5.48",
                applicationIcon: const Icon(
                  Icons.health_and_safety,
                  size: 40,
                  color: kPrimaryAccent,
                ),
                children: [
                  const Text(
                    "Project HOPE is a mental health companion app developed by Tech AI Inc. This prototype demonstrates the potential of AI-driven support and diagnostics in a user-friendly mobile experience. All features are for demonstration purposes only and not intended for medical use.",
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
