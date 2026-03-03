import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🟢 ADDED for future DB calls
import '../screens/level_map_screen.dart';

class ScoreScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int grade;
  final int level;
  final int masterLevelId; // 🟢 ADDED: Master DB Level (26 to 115)

  const ScoreScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.grade,
    required this.level,
    required this.masterLevelId, // 🟢 ADDED
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  bool isPassed = false;
  int xpEarned = 0;
  int starCount = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _calculateAndSaveProgress();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _calculateAndSaveProgress() async {
    double percentage = widget.score / widget.totalQuestions;

    // We update the UI state synchronously first
    setState(() {
      isPassed = percentage >= 0.5;

      if (percentage == 1.0) {
        starCount = 3;
      } else if (percentage >= 0.7) {
        starCount = 2;
      } else if (percentage >= 0.5) {
        starCount = 1;
      } else {
        starCount = 0;
      }

      if (isPassed) {
        xpEarned = widget.score * 50;
      }
    });

    try {
      if (isPassed) {
        await _audioPlayer.play(AssetSource('sounds/victory.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/fail.mp3'));
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }

    // 🟢 AUTHENTICATION BYPASSED FOR API TESTING
    if (isPassed) {
      print("🎯 API TEST SUCCESS: Child passed UI Level ${widget.level}!");
      print("💾 Ready to save to Master DB Level ID: ${widget.masterLevelId}");
      print("⭐ Earned: $starCount Stars and $xpEarned XP.");

      /* --- UNCOMMENT THIS LATER WHEN AUTHENTICATION IS TURNED ON ---
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user != null) {
          // 1. Save the level score to student_game_state table
          await supabase.from('student_game_state').upsert({
            'student_id': user.id,
            'game_level_id': widget.masterLevelId, // 🟢 USING THE MASTER ID!
            'stars': starCount,
            'score': widget.score,
            'status': 'COMPLETED'
          });

          // 2. Fetch current profile to check their overall progress
          final profileData = await supabase
              .from('profiles')
              .select('game_level, xp')
              .eq('id', user.id)
              .single();
              
          int currentHighestLevel = profileData['game_level'] ?? 1;
          int currentXP = profileData['xp'] ?? 0;

          // 3. If they beat their highest level, unlock the next one!
          int nextLevel = (widget.level >= currentHighestLevel) 
              ? currentHighestLevel + 1 
              : currentHighestLevel;

          // 4. Update the profile
          await supabase.from('profiles').update({
            'game_level': nextLevel,
            'xp': currentXP + xpEarned,
          }).eq('id', user.id);
          
          print("✅ Progress successfully saved to Group Database!");
        }
      } catch (e) {
        print("❌ Error saving progress to Supabase: $e");
      }
      -------------------------------------------------------------- */
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LevelMapScreen(grade: widget.grade)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPassed
                ? [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)]
                : [const Color(0xFFFFCC80), const Color(0xFFEF5350)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 3,
                  child: isPassed
                      ? Lottie.asset(
                          'assets/animations/Champion.json',
                          repeat: true,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.emoji_events,
                              size: 100,
                              color: Colors.white),
                        )
                      : const Icon(Icons.sentiment_very_dissatisfied_rounded,
                          size: 120, color: Colors.white),
                ),
                Text(
                  isPassed ? "ජයග්‍රහණය!" : "නැවත උත්සාහ කරන්න",
                  style: GoogleFonts.notoSansSinhala(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(0, 4))
                      ]),
                ),
                const SizedBox(height: 10),
                ClayContainer(
                  color: Colors.white,
                  borderRadius: 30,
                  depth: 40,
                  spread: 2,
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPassed)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Icon(
                                Icons.star_rounded,
                                size: 45,
                                color: index < starCount
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                              );
                            }),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          "ලකුණු (Score)",
                          style: GoogleFonts.notoSansSinhala(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.score} / ${widget.totalQuestions}",
                          style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.blue : Colors.redAccent),
                        ),
                        const SizedBox(height: 10),
                        if (isPassed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Colors.orange, size: 24),
                                Text(
                                  "+$xpEarned XP",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _goHome,
                  child: ClayContainer(
                    color: isPassed
                        ? Colors.green.shade400
                        : Colors.orange.shade400,
                    borderRadius: 30,
                    depth: 25,
                    spread: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Text(
                        isPassed ? "ඉදිරියට යන්න" : "නැවත මුලට",
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
