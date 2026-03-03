import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../story/models/quiz_model.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String storyText;
  final int grade;
  final int level;
  final int masterLevelId; // 🟢 ADDED: Master DB Level (26 to 115)

  const QuizScreen({
    super.key,
    required this.questions,
    required this.storyText,
    required this.grade,
    required this.level,
    required this.masterLevelId, // 🟢 ADDED
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;

  bool _showConfetti = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleAnswer(int selectedIndex) async {
    if (_isAnswered) return;

    bool isCorrect =
        selectedIndex == widget.questions[_currentIndex].correctAnswerIndex;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = selectedIndex;
    });

    try {
      if (isCorrect) {
        _score++;
        setState(() => _showConfetti = true);
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            score: _score,
            totalQuestions: widget.questions.length,
            grade: widget.grade,
            level: widget.level,
            masterLevelId:
                widget.masterLevelId, // 🟢 PASSED FORWARD TO FINAL SCREEN
          ),
        ),
      );
    }
  }

  void _showStoryHint(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "📖 කතාව",
                style: GoogleFonts.notoSansSinhala(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue.shade900),
              ),
              const SizedBox(height: 16),
              Text(
                widget.storyText,
                style: GoogleFonts.notoSansSinhala(
                    fontSize: 18, height: 1.6, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "හරි, දැන් ප්‍රශ්නයට යමු!",
                    style: GoogleFonts.notoSansSinhala(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("ප්‍රශ්න සොයාගත නොහැක.")));
    }

    final question = widget.questions[_currentIndex];
    double progress = (_currentIndex + 1) / widget.questions.length;

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showStoryHint(context),
            backgroundColor: Colors.blue.shade400,
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
            label: Text(
              "කතාව බලමු",
              style: GoogleFonts.notoSansSinhala(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: ClayContainer(
              color: Colors.white,
              borderRadius: 20,
              depth: 10,
              spread: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "ප්‍රශ්න අංක ${_currentIndex + 1}",
                  style: GoogleFonts.notoSansSinhala(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81D4FA), Color(0xFFAED581)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 3))
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 18,
                              backgroundColor: Colors.white.withOpacity(0.5),
                              color: Colors.orange.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ClayContainer(
                          color: Colors.white,
                          borderRadius: 25,
                          depth: 30,
                          spread: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 20),
                            constraints: const BoxConstraints(minHeight: 140),
                            child: Center(
                              child: Text(
                                question.question,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSansSinhala(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.deepPurple.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: question.options.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildOptionButton(
                                  index,
                                  question.options[index],
                                  question.correctAnswerIndex);
                            },
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/Confetti.json',
                repeat: false,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton(int index, String text, int correctIndex) {
    Color baseColor = Colors.white;
    Color textColor = Colors.black87;
    IconData? statusIcon;
    int depth = 20;

    if (_isAnswered) {
      if (index == correctIndex) {
        baseColor = Colors.green.shade500;
        textColor = Colors.white;
        statusIcon = Icons.check_circle_rounded;
        depth = 5;
      } else if (index == _selectedOptionIndex) {
        baseColor = Colors.red.shade400;
        textColor = Colors.white;
        statusIcon = Icons.cancel_rounded;
        depth = 5;
      } else {
        baseColor = Colors.grey.shade200;
        textColor = Colors.grey.shade500;
        depth = 2;
      }
    }

    return GestureDetector(
      onTap: () => _handleAnswer(index),
      child: ClayContainer(
        color: baseColor,
        borderRadius: 20,
        depth: depth,
        spread: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isAnswered &&
                          (index == correctIndex ||
                              index == _selectedOptionIndex)
                      ? Colors.white.withOpacity(0.3)
                      : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: statusIcon != null
                      ? Icon(statusIcon, color: Colors.white, size: 24)
                      : Text(
                          "${index + 1}",
                          style: GoogleFonts.notoSansSinhala(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.orange.shade900),
                        ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
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
