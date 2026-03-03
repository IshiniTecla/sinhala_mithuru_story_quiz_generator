import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'level_map_screen.dart'; // 🟢 Make sure this path is correct

class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  void _selectGrade(BuildContext context, int grade) {
    // 🟢 FIX: Removed 'const' and added 'grade: grade'
    // Changed to Navigator.push so the user can go back to select another grade.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LevelMapScreen(grade: grade)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9C4), // Very light Blue/Yellow mix
              Color(0xFFFFCC80), // Orange
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🟢 TITLE
                      ClayContainer(
                        color: Colors.white,
                        borderRadius: 20,
                        depth: 10,
                        spread: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: Text(
                            "ඔබගේ ශ්‍රේණිය තෝරන්න", // Select your grade
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSansSinhala(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 🟢 GRADE BUTTONS
                      _buildGradeButton(context, "1 ශ්‍රේණිය", 1,
                          Colors.pink.shade300, Icons.looks_one_rounded),
                      const SizedBox(height: 20),

                      _buildGradeButton(context, "2 ශ්‍රේණිය", 2,
                          Colors.orange.shade400, Icons.looks_two_rounded),
                      const SizedBox(height: 20),

                      _buildGradeButton(context, "3 ශ්‍රේණිය", 3,
                          Colors.green.shade400, Icons.looks_3_rounded),
                      const SizedBox(height: 20),

                      _buildGradeButton(context, "4 ශ්‍රේණිය", 4,
                          Colors.blue.shade400, Icons.looks_4_rounded),
                      const SizedBox(height: 20),

                      _buildGradeButton(context, "5 ශ්‍රේණිය", 5,
                          Colors.purple.shade300, Icons.looks_5_rounded),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🟢 Helper Widget to create beautiful 3D Grade Buttons
  Widget _buildGradeButton(BuildContext context, String text, int grade,
      Color color, IconData icon) {
    return GestureDetector(
      onTap: () => _selectGrade(context, grade),
      child: ClayContainer(
        color: color,
        borderRadius: 25,
        depth: 30,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded,
                  color: Colors.white, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
