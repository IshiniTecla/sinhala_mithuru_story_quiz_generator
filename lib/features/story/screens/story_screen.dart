import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_model.dart';
import 'quiz_screen.dart';

class StoryScreen extends StatefulWidget {
  final String storyText;
  final Future<List<QuizQuestion>> quizFuture;
  final int grade;
  final int level;
  final int masterLevelId;

  const StoryScreen({
    super.key,
    required this.storyText,
    required this.quizFuture,
    required this.grade,
    required this.level,
    required this.masterLevelId,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late List<String> _fixedSentences;
  late List<String> _shuffledSentences;
  late List<String> _correctShuffledOrder;

  bool _isSolved = false;
  bool _hasCheckedOnce = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showCongratulations = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Color> _blockColors = [
    Colors.pink.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _initializeDynamicPuzzle();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });
  }

// 🟢 FIXED: The Adaptive Scaffolding Algorithm (Dynamically handles ANY length!) 🟢
  void _initializeDynamicPuzzle() {
    // 1. Split the AI story cleanly and keep the full stops (.)
    List<String> allSentences = widget.storyText
        .split('.')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty) // This ignores accidental extra spaces!
        .map((s) => "$s.")
        .toList();

    // 2. SAFETY CHECK: If AI fails and generates nothing, don't crash!
    if (allSentences.isEmpty) {
      allSentences = ["කතාවක් නැත."];
    }

    int shuffleCount = 2; // Base default (Shuffle exactly the last 2)

    // 3. Set difficulty based on the Grade and Level
    if (widget.grade == 1) {
      // 🟢 GRADE 1 RULES (Map Levels 11 to 20)
      if (widget.level >= 11 && widget.level <= 15) {
        shuffleCount = 2; // First 5 Levels -> Shuffle ONLY the last 2
      } else if (widget.level >= 16 && widget.level <= 20) {
        shuffleCount = 3; // Next 5 Levels -> Shuffle ONLY the last 3
      }
    } else {
      // 🟢 GRADES 2, 3, 4, 5 RULES (Map Levels 1 to 20)
      if (widget.level >= 1 && widget.level <= 5) {
        shuffleCount = 2; // Levels 1-5 -> Shuffle ONLY the last 2
      } else if (widget.level >= 6 && widget.level <= 10) {
        shuffleCount = 3; // Levels 6-10 -> Shuffle ONLY the last 3
      } else if (widget.level >= 11 && widget.level <= 15) {
        shuffleCount = 4; // Levels 11-15 -> Shuffle ONLY the last 4
      } else if (widget.level >= 16) {
        shuffleCount = allSentences.length; // Levels 16-20 -> Shuffle ALL
      }
    }

    // 4. BULLETPROOF MATH:
    // If the AI accidentally generates fewer sentences than we want to shuffle,
    // we cap the shuffleCount so the app doesn't crash!
    if (shuffleCount > allSentences.length) {
      shuffleCount = allSentences.length;
    }

    // 5. THE MAGIC CALCULATION: Total Sentences minus Shuffle Count
    // This guarantees it is ALWAYS the exact "last N sentences" regardless of story length!
    int fixedCount = allSentences.length - shuffleCount;

    setState(() {
      // Lock the first sentences at the top of the screen
      _fixedSentences = allSentences.sublist(0, fixedCount);

      // Grab the exact last N sentences for the puzzle
      _correctShuffledOrder = allSentences.sublist(fixedCount);

      // Create the shuffled draggable blocks
      _shuffledSentences = List.from(_correctShuffledOrder);
      _shuffledSentences.shuffle();

      // Ensure it doesn't accidentally shuffle into the correct order by pure luck
      while (listEquals(_shuffledSentences, _correctShuffledOrder) &&
          _shuffledSentences.length > 1) {
        _shuffledSentences.shuffle();
      }
    });

    // Optional: Print to your console to prove it's working!
    debugPrint("🤖 AI generated ${allSentences.length} sentences.");
    debugPrint("🔒 Locked the first $fixedCount sentences.");
    debugPrint("🔀 Shuffled the last $shuffleCount sentences.");
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final String item = _shuffledSentences.removeAt(oldIndex);
      _shuffledSentences.insert(newIndex, item);
      _hasCheckedOnce = false;
    });
  }

  void _resetPuzzle() {
    setState(() {
      _shuffledSentences.shuffle();
      while (listEquals(_shuffledSentences, _correctShuffledOrder) &&
          _shuffledSentences.length > 1) {
        _shuffledSentences.shuffle();
      }
      _hasCheckedOnce = false;
      _isSolved = false;
    });
  }

  Future<void> _checkOrder() async {
    setState(() => _hasCheckedOnce = true);

    if (listEquals(_shuffledSentences, _correctShuffledOrder)) {
      try {
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        debugPrint("Error playing sound: $e");
      }

      setState(() {
        _isSolved = true;
        _showCongratulations = true;
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showCongratulations = false);
      });
    } else {
      _shakeController.forward();
      _showFeedback("තවම හරි නැහැ! ආයේ හදමු. 🧩", Colors.redAccent,
          Icons.warning_amber_rounded);
    }
  }

  Future<void> _navigateToQuiz() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 8),
      ),
    );

    List<QuizQuestion> finalQuiz;
    try {
      finalQuiz = await widget.quizFuture;
    } catch (e) {
      debugPrint("Background Quiz Failed: $e");
      finalQuiz = [
        QuizQuestion(
          question: "කතාව හොඳින් කියෙව්වාද?",
          options: ["ඔව්", "නැහැ", "මතක නැහැ"],
          correctAnswerIndex: 0,
        )
      ];
    }

    if (mounted) Navigator.pop(context);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            questions: finalQuiz,
            storyText: widget.storyText,
            grade: widget.grade,
            level: widget.level,
            masterLevelId: widget.masterLevelId,
          ),
        ),
      );
    }
  }

  void _showFeedback(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(msg,
              style: GoogleFonts.notoSansSinhala(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: ClayContainer(
              color: Colors.white,
              borderRadius: 30,
              depth: 15,
              spread: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.extension_rounded, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(
                      "කතාව හදමු",
                      style: GoogleFonts.notoSansSinhala(
                          fontSize: 22,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81D4FA), Color(0xFFAED581)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_fixedSentences.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: ClayContainer(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: 20,
                        depth: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _fixedSentences.join(" "),
                            style: GoogleFonts.notoSansSinhala(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ReorderableListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          onReorder: _onReorder,
                          buildDefaultDragHandles: false,
                          children: [
                            for (int index = 0;
                                index < _shuffledSentences.length;
                                index++)
                              _buildPuzzleBlock(
                                  index, _shuffledSentences[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSolved ? null : _resetPuzzle,
                            child: Opacity(
                              opacity: _isSolved ? 0.5 : 1.0,
                              child: ClayContainer(
                                color: Colors.blue.shade400,
                                borderRadius: 50,
                                depth: 20,
                                spread: 1,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.refresh_rounded,
                                          color: Colors.white, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        "නැවත හදමු",
                                        style: GoogleFonts.notoSansSinhala(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    _shakeAnimation.value *
                                        (1 - (_shakeController.value * 2))
                                            .sign *
                                        5,
                                    0),
                                child: child,
                              );
                            },
                            child: GestureDetector(
                              onTap: _isSolved ? _navigateToQuiz : _checkOrder,
                              child: ClayContainer(
                                color: _isSolved
                                    ? Colors.green.shade500
                                    : Colors.orange.shade500,
                                borderRadius: 50,
                                depth: 25,
                                spread: 2,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          _isSolved
                                              ? Icons.arrow_forward_rounded
                                              : Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isSolved
                                            ? "ප්‍රශ්න වලට යමු"
                                            : "හරිද බලමු",
                                        style: GoogleFonts.notoSansSinhala(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showCongratulations)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Lottie.asset(
                  'assets/animations/Confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPuzzleBlock(int index, String text) {
    Color blockColor = _blockColors[index % _blockColors.length];

    return ReorderableDragStartListener(
      key: ValueKey(text),
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        child: ClayContainer(
          color: blockColor,
          borderRadius: 20,
          depth: 25,
          spread: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.drag_indicator_rounded,
                      color: Colors.black45, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.notoSansSinhala(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
