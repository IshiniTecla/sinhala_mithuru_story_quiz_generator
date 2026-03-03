import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:clay_containers/clay_containers.dart';
import 'grade_selection_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _startAdventure(BuildContext context) {
    // 🟢 Navigate to Grade Selection instead of Level Map
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GradeSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFDEE9), // Light Pink
              Color(0xFFB5FFFC), // Light Blue
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. App Name
                Text(
                  "සිංහල මිතුරු",
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                    shadows: [
                      const Shadow(
                        blurRadius: 3.0,
                        color: Colors.black12,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Welcome Message
                Text(
                  "පුංචි අපේ කතන්දර ලෝකය",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple.shade700,
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Animation
                SizedBox(
                  height: 300,
                  child: Lottie.asset(
                    'assets/animations/animals_playing.json',
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.videogame_asset,
                          size: 100, color: Colors.orange);
                    },
                  ),
                ),

                const SizedBox(height: 50),

                // 4. "Go Forward" Button (Shorter & 3D)
                GestureDetector(
                  onTap: () => _startAdventure(context),
                  child: ClayContainer(
                    color: Colors.orange, // Button Color
                    borderRadius: 50, // Very rounded
                    depth: 20, // 3D Pop
                    spread: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // 🟢 This makes the button shorter!
                        children: [
                          Text(
                            "ඉදිරියට යන්න",
                            style: GoogleFonts.notoSansSinhala(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 28),
                        ],
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
