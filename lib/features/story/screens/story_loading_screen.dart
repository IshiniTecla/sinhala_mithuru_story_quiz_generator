import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:clay_containers/clay_containers.dart';
import 'story_screen.dart';
import '../models/quiz_model.dart';
import '../data/fallback_data.dart';
import '../services/story_api_service.dart';

// Model for our floating balloons
class GameBalloon {
  final int id;
  double x;
  double y;
  double speed;
  Color color;
  bool isPopped;

  GameBalloon({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    this.isPopped = false,
  });
}

class StoryLoadingScreen extends StatefulWidget {
  final int grade;
  final String theme;
  final String contextText;
  final int sequenceId;
  final int masterLevelId; // 🟢 ADDED: Master DB Level (26 to 115)

  const StoryLoadingScreen({
    super.key,
    required this.grade,
    required this.theme,
    required this.contextText,
    required this.sequenceId,
    required this.masterLevelId, // 🟢 ADDED
  });

  @override
  State<StoryLoadingScreen> createState() => _StoryLoadingScreenState();
}

class _StoryLoadingScreenState extends State<StoryLoadingScreen> {
  String _loadingStatus = "ඔබගේ කතාව නිර්මාණය වෙමින් පවතී... 🚀";

  // Mini-Game Variables
  int _score = 0;
  Timer? _gameLoop;
  final Random _random = Random();
  final List<GameBalloon> _balloons = [];

  final List<Color> _balloonColors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _initMiniGame();
    _generateLiveStoryAndQuiz();
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  void _initMiniGame() {
    for (int i = 0; i < 6; i++) {
      _balloons.add(_createNewBalloon(i, initialDelay: true));
    }

    _gameLoop = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      setState(() {
        for (var balloon in _balloons) {
          if (!balloon.isPopped) {
            balloon.y -= balloon.speed;
            if (balloon.y < -1.5) {
              _resetBalloon(balloon);
            }
          }
        }
      });
    });
  }

  GameBalloon _createNewBalloon(int id, {bool initialDelay = false}) {
    double startY = initialDelay ? 1.2 + (_random.nextDouble() * 2) : 1.2;
    return GameBalloon(
      id: id,
      x: (_random.nextDouble() * 1.8) - 0.9,
      y: startY,
      speed: 0.015 + (_random.nextDouble() * 0.02),
      color: _balloonColors[_random.nextInt(_balloonColors.length)],
    );
  }

  void _resetBalloon(GameBalloon balloon) {
    balloon.x = (_random.nextDouble() * 1.8) - 0.9;
    balloon.y = 1.2 + (_random.nextDouble() * 0.5);
    balloon.speed = 0.015 + (_random.nextDouble() * 0.02);
    balloon.color = _balloonColors[_random.nextInt(_balloonColors.length)];
    balloon.isPopped = false;
  }

  void _popBalloon(GameBalloon balloon) {
    if (balloon.isPopped) return;
    setState(() {
      balloon.isPopped = true;
      _score += 15;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _resetBalloon(balloon);
        });
      }
    });
  }

  // 🟢 MODIFIED: Asynchronous Background Generation
  Future<void> _generateLiveStoryAndQuiz() async {
    try {
      setState(() => _loadingStatus = "ලස්සන කතාවක් ලියමින් පවතී... ✍️✨");

      // 1. AWAIT ONLY THE STORY (Much faster!)
      String generatedStory = await StoryApiService.generateStory(
        grade: widget.grade,
        theme: widget.theme,
        contextText: widget.contextText,
      );

      // 2. START THE QUIZ IN THE BACKGROUND (No 'await' here!)
      Future<List<QuizQuestion>> quizFuture = StoryApiService.generateQuiz(
        storyText: generatedStory,
        grade: widget.grade,
      );

      // 3. Navigate instantly with the story and the background task
      _navigateToStory(generatedStory, quizFuture);
    } catch (e) {
      debugPrint("API Error: $e. Loading fallback content.");

      // If the Story fails, load offline data instantly
      final offlineData =
          FallbackData.getFallback(widget.grade, widget.sequenceId);

      // Wrap the offline quiz in a completed Future so it matches the new logic
      _navigateToStory(offlineData.story, Future.value(offlineData.quiz));
    }
  }

  // 🟢 CHANGED: Now accepts a Future<List<QuizQuestion>> instead of a normal list
  void _navigateToStory(String story, Future<List<QuizQuestion>> quizFuture) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StoryScreen(
            storyText: story,
            quizFuture: quizFuture, // Pass the background task
            grade: widget.grade,
            level: widget.sequenceId,
            masterLevelId: widget.masterLevelId, // 🟢 PASSED FORWARD
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81D4FA), Color(0xFFFFF9C4), Color(0xFFFFCC80)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._balloons.map((balloon) {
                return Align(
                  alignment: Alignment(balloon.x, balloon.y),
                  child: GestureDetector(
                    onTap: () => _popBalloon(balloon),
                    child: balloon.isPopped
                        ? const Text("💥", style: TextStyle(fontSize: 60))
                        : ClayContainer(
                            color: balloon.color,
                            height: 80,
                            width: 65,
                            borderRadius: 50,
                            depth: 20,
                            spread: 2,
                            child: const Center(
                              child: Text("🎈", style: TextStyle(fontSize: 30)),
                            ),
                          ),
                  ),
                );
              }),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ClayContainer(
                    color: Colors.white,
                    borderRadius: 20,
                    depth: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Text(
                        "ලකුණු: $_score",
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "කතාව හැදෙනකන් බැලුම් පුපුරවමු! 🎈",
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 120,
                        child: Lottie.asset(
                          'assets/animations/loading_book.json',
                          errorBuilder: (context, error, stackTrace) =>
                              const CircularProgressIndicator(
                                  color: Colors.orange, strokeWidth: 6),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _loadingStatus,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepOrange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
