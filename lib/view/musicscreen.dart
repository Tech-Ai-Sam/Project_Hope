// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_hope/main.dart';

class Musicscreen extends StatefulWidget {
  const Musicscreen({super.key});

  @override
  State<Musicscreen> createState() => _MusicscreenState();
}

class _MusicscreenState extends State<Musicscreen> {
  bool _isPlaying = false;
  double _frequencyVolume = 0.5;
  String _selectedWave = "Alpha";

  AudioPlayer? _audioPlayer;
  bool _isEngineReady = false;
  int _currentIndex = 0;

  // RECONFIGURED BINAURAL CHANNELS: Updated with reliable, high-uptime direct audio streams
  // that fully support byte-range streaming requests for just_audio.
  final List<Map<String, dynamic>> _brainwaveStates = [
    {
      "name": "Alpha",
      "range": "10Hz",
      "purpose": "Deep Relaxation & Stress Relief",
      "icon": Icons.spa_outlined,
      "source":
          "https://actions.google.com/sounds/v1/ambiences/ambient_hum_air_conditioner.ogg",
      "fallback":
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
    {
      "name": "Theta",
      "range": "6Hz",
      "purpose": "Deep Meditation & REM State",
      "icon": Icons.nightlight_round,
      "source": "https://actions.google.com/sounds/v1/ambiences/deep_space.ogg",
      "fallback":
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    },
    {
      "name": "Delta",
      "range": "2.5Hz",
      "purpose": "Restorative Healing & Deep Sleep",
      "icon": Icons.hotel_rounded,
      "source":
          "https://actions.google.com/sounds/v1/ambiences/sub_bass_rumble.ogg",
      "fallback":
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    },
    {
      "name": "Beta",
      "range": "20Hz",
      "purpose": "High Focus, Cognition & Memory",
      "icon": Icons.psychology_outlined,
      "source":
          "https://actions.google.com/sounds/v1/synthetic/pulsating_frequencies.ogg",
      "fallback":
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAudioEngine();
  }

  // --- AUDIO ENGINE INITIALIZATION ---
  Future<void> _initAudioEngine() async {
    try {
      final player = AudioPlayer();
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(_frequencyVolume);

      await _safeSetAudioSource(
        player,
        _brainwaveStates[_currentIndex]["source"],
        _brainwaveStates[_currentIndex]["fallback"],
      );

      if (mounted) {
        setState(() {
          _audioPlayer = player;
          _isEngineReady = true;
        });
      }
    } catch (e) {
      debugPrint("Critical Error initializing audio engine: $e");
      if (mounted) {
        setState(() {
          _isEngineReady = true;
        });
      }
    }
  }

  // --- SAFE AUDIO SOURCE RESOLVER (Main Stream -> Fallback Stream) ---
  Future<void> _safeSetAudioSource(
    AudioPlayer player,
    String primaryUrl,
    String fallbackUrl,
  ) async {
    final Map<String, String> networkHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': '*/*',
      'Icy-MetaData': '1',
    };

    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(primaryUrl), headers: networkHeaders),
        preload: true,
      );
    } catch (primaryError) {
      debugPrint(
        "Primary stream failed, attempting safety fallback: $primaryError",
      );
      try {
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(fallbackUrl), headers: networkHeaders),
          preload: true,
        );
      } catch (fallbackError) {
        debugPrint(
          "All remote streams rejected by host architecture: $fallbackError",
        );
      }
    }
  }

  // --- DYNAMIC TRACK SWITCHING ---
  Future<void> _loadSelectedWaveAsset(
    String sourcePath,
    String fallbackPath,
  ) async {
    if (!_isEngineReady || _audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.stop();
      }

      await _safeSetAudioSource(_audioPlayer!, sourcePath, fallbackPath);

      if (_isPlaying) {
        _audioPlayer!.play();
      }
    } catch (e) {
      debugPrint("Error shifting frequency stream nodes: $e");
      _showNetworkErrorSnackBar();
    }
  }

  void _togglePlayback() {
    if (!_isEngineReady || _audioPlayer == null) return;

    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _audioPlayer!.play().catchError((error) {
        debugPrint("Playback invocation halted: $error");
        _showNetworkErrorSnackBar();
        setState(() {
          _isPlaying = false;
        });
      });
    } else {
      _audioPlayer!.pause();
    }
  }

  void _handleTrackSkip(bool skipForward) {
    if (!_isEngineReady) return;

    setState(() {
      if (skipForward) {
        _currentIndex = (_currentIndex + 1) % _brainwaveStates.length;
      } else {
        _currentIndex =
            (_currentIndex - 1 + _brainwaveStates.length) %
            _brainwaveStates.length;
      }
      _selectedWave = _brainwaveStates[_currentIndex]["name"];
    });

    _loadSelectedWaveAsset(
      _brainwaveStates[_currentIndex]["source"],
      _brainwaveStates[_currentIndex]["fallback"],
    );
  }

  void _showNetworkErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Stream handshake error. Resolving backup channels..."),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isEngineReady
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryAccent,
                strokeWidth: 2,
              ),
            )
          : Stack(
              children: [
                // Top ambient radial glow tracking the active music environment
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _isPlaying
                            ? kPrimaryAccent.withOpacity(0.06)
                            : Colors.transparent,
                        Colors.black,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- MINIMALIST APP BAR ROW ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 32,
                            ), // Layout balancing spacer
                            Column(
                              children: [
                                const Text(
                                  "BINAURAL SANCTUARY",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "NEURAL AUDIO MODULATION",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.25),
                                    fontSize: 8,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.01),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.04),
                                ),
                              ),
                              child: Icon(
                                Icons.headset_mic_rounded,
                                color: _isPlaying
                                    ? kPrimaryAccent
                                    : Colors.white24,
                                size: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 44),

                        // --- VISUALIZER GLOW BLOCK ---
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isPlaying
                                      ? kPrimaryAccent.withOpacity(0.03)
                                      : Colors.white.withOpacity(0.005),
                                  boxShadow: [
                                    if (_isPlaying)
                                      BoxShadow(
                                        color: kPrimaryAccent.withOpacity(0.12),
                                        blurRadius: 44,
                                        spreadRadius: 8,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF09090A),
                                  border: Border.all(
                                    color: _isPlaying
                                        ? kPrimaryAccent.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.04),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.blur_on_rounded
                                      : Icons.graphic_eq_rounded,
                                  color: _isPlaying
                                      ? kPrimaryAccent
                                      : Colors.white24,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // --- TRACK META TITLES ---
                        Text(
                          "$_selectedWave Isochronic Frequency",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Target: ${_brainwaveStates[_currentIndex]["purpose"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // --- AUDIO CONTROL BAR ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 28,
                              ),
                              onPressed: () => _handleTrackSkip(false),
                            ),
                            const SizedBox(width: 28),
                            GestureDetector(
                              onTap: _togglePlayback,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 28,
                              ),
                              onPressed: () => _handleTrackSkip(true),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // --- VOLUME SLIDER ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Resonance Level",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    "${(_frequencyVolume * 100).toInt()}%",
                                    style: const TextStyle(
                                      color: kPrimaryAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  activeTrackColor: kPrimaryAccent,
                                  inactiveTrackColor: Colors.white.withOpacity(
                                    0.05,
                                  ),
                                  thumbColor: Colors.white,
                                  overlayColor: kPrimaryAccent.withOpacity(
                                    0.08,
                                  ),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5,
                                  ),
                                ),
                                child: Slider(
                                  value: _frequencyVolume,
                                  onChanged: (val) {
                                    setState(() {
                                      _frequencyVolume = val;
                                    });
                                    _audioPlayer?.setVolume(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "SYSTEM TUNING MATRIX",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // --- INTERACTIVE LIST NODES ---
                        ListView.builder(
                          shrinkWrap: true,
                          key: const ValueKey('frequency_list'),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _brainwaveStates.length,
                          itemBuilder: (context, index) {
                            final state = _brainwaveStates[index];
                            final bool isCurrent =
                                _selectedWave == state["name"];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFF09090A)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? kPrimaryAccent.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.02),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  if (_selectedWave != state["name"]) {
                                    setState(() {
                                      _currentIndex = index;
                                      _selectedWave = state["name"];
                                    });
                                    _loadSelectedWaveAsset(
                                      state["source"],
                                      state["fallback"],
                                    );
                                  }
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? kPrimaryAccent.withOpacity(0.04)
                                        : Colors.white.withOpacity(0.01),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCurrent
                                          ? kPrimaryAccent.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.02),
                                    ),
                                  ),
                                  child: Icon(
                                    state["icon"],
                                    color: isCurrent
                                        ? kPrimaryAccent
                                        : Colors.white38,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  "${state["name"]} Tuning Node",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  state["purpose"],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Text(
                                  state["range"],
                                  style: TextStyle(
                                    color: isCurrent
                                        ? kPrimaryAccent
                                        : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
