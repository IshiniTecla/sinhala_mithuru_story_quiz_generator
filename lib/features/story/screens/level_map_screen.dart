import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_loading_screen.dart';
import '../data/level_data.dart';

class LevelMapScreen extends StatefulWidget {
  final int grade;

  const LevelMapScreen({super.key, required this.grade});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen>
    with SingleTickerProviderStateMixin {
  late int _studentGrade;
  int _unlockedLevel = 20; // Default to 20 for testing
  String _studentName = "යාලුවා";
  bool _isLoading = true;

  // Uses the LevelMission class from level_data.dart
  List<LevelMission> _levels = [];

  // 🟢 Stores the mapping of Display Level (1-20) -> Master DB ID (26-115)
  Map<int, int> _masterLevelMap = {};

  late AnimationController _bouncer;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _studentGrade = widget.grade;

    _initializeData();

    _bouncer = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bouncer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bouncer.dispose();
    super.dispose();
  }

  // Fetch Data from Supabase Table
  Future<void> _initializeData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final profileData = await supabase
            .from('profiles')
            .select('student_grade, game_level, name')
            .eq('id', user.id)
            .single();

        _studentGrade = profileData['student_grade'] ?? widget.grade;
        _unlockedLevel = profileData['game_level'] ?? 1;
        _studentName = profileData['name'] ?? "යාලුවා";
      } else {
        _studentGrade = widget.grade;
        _unlockedLevel = 20; // Unlock all for testing
        _studentName = "පරීක්ෂක (Tester)";
      }

      // 🟢 THE FIX: Relational Inner Join with game_levels
      final levelData = await supabase
          .from('content_narrative')
          .select('''
            level_id, 
            theme, 
            context, 
            task_name,
            game_levels!inner (
              grade,
              level_number
            )
          ''')
          .eq('game_levels.grade', _studentGrade)
          .order('level_id',
              ascending:
                  true); // 🟢 FIX 1: ORDER BY LOCAL ID TO PREVENT SUPABASE CRASH

      List<LevelMission> fetchedLevels = [];
      Map<int, int> fetchedMasterMap = {};

      for (var row in levelData) {
        final gameLevelInfo = row['game_levels'];

        // This is the UI number (1 to 20) for drawing the map
        int displayLevelId = gameLevelInfo['level_number'] ?? 1;

        // This is the master database ID (26 to 115) for saving later
        int masterLevelId = row['level_id'];

        // Save to our secret mapping dictionary
        fetchedMasterMap[displayLevelId] = masterLevelId;

        String dbTheme = row['theme'] ?? 'general';
        String contextText = row['context'] ?? 'ලස්සන කතාවක්.';
        String taskName = row['task_name'] ?? 'පියවර $displayLevelId';

        // Use your separated helper class
        final themeData = LevelUIHelper.getThemeData(dbTheme);

        fetchedLevels.add(LevelMission(
          level: displayLevelId, // Keeps the UI mapping 1-20
          theme: themeData.sinhalaTheme,
          context: contextText,
          color: themeData.color,
          icon: themeData.icon,
          description: taskName,
        ));
      }

      if (mounted) {
        setState(() {
          _levels = fetchedLevels;
          _masterLevelMap = fetchedMasterMap; // Save map to state
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching from Supabase: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onLevelTap(LevelMission mission) {
    if (mission.level > _unlockedLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("මෙම පියවර තවම අගුළු දමා ඇත! (Locked)",
              style: GoogleFonts.notoSansSinhala(fontSize: 16)),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
      return;
    }

    // Grab the actual master database ID (e.g., 26) using the UI level (e.g., 1)
    int actualMasterId = _masterLevelMap[mission.level] ?? mission.level;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryLoadingScreen(
          grade: _studentGrade,
          theme: mission.theme,
          contextText: mission.context,
          sequenceId:
              mission.level, // We keep this as 1-20 for your Fallback stories!
          masterLevelId:
              actualMasterId, // 🟢 FIX 2: PASSED FORWARD SO SCORE SCREEN CAN SAVE!
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.orange)));
    }

    if (_levels.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("දෝෂයකි")),
        body: const Center(
            child: Text("Database levels not found! Add data to Supabase.")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.orange.shade100, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Text(
            "$_studentGrade ශ්‍රේණිය (Grade $_studentGrade)",
            style: GoogleFonts.notoSansSinhala(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back_rounded, color: Colors.orange),
                onPressed: _logout,
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFFAED581)],
            stops: [0.2, 0.9],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
                top: 100,
                left: -20,
                child: Icon(Icons.cloud,
                    size: 100, color: Colors.white.withOpacity(0.3))),
            Positioned(
                top: 150,
                right: -30,
                child: Icon(Icons.cloud,
                    size: 120, color: Colors.white.withOpacity(0.3))),
            Positioned(
                bottom: 50,
                left: 20,
                child: Icon(Icons.grass,
                    size: 80, color: Colors.green.shade700.withOpacity(0.2))),
            ListView.builder(
              padding: const EdgeInsets.only(top: 120, bottom: 100),
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final mission = _levels[index];
                return _buildPathNode(index, mission);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathNode(int index, LevelMission mission) {
    bool isLocked = mission.level > _unlockedLevel;
    bool isCurrent = mission.level == _unlockedLevel;
    bool isCompleted = mission.level < _unlockedLevel;

    double alignment = 0.0;
    if (index % 4 == 0)
      alignment = 0.0;
    else if (index % 4 == 1)
      alignment = 0.4;
    else if (index % 4 == 2)
      alignment = 0.0;
    else if (index % 4 == 3) alignment = -0.4;

    return Align(
      alignment: Alignment(alignment, 0),
      child: Column(
        children: [
          if (index > 0)
            Container(
              height: 30,
              width: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              double offset = isCurrent ? -_bounceAnimation.value : 0;
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () => _onLevelTap(mission),
              child: Container(
                width: isCurrent ? 95 : 80,
                height: isCurrent ? 90 : 75,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade400 : mission.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isLocked
                          ? Colors.grey.shade600
                          : mission.color.withOpacity(0.6),
                      blurRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    if (isCurrent)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: isCurrent ? 5 : 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isLocked
                          ? Icons.lock
                          : (isCompleted ? Icons.check_rounded : mission.icon),
                      color: Colors.white,
                      size: isCurrent ? 36 : 30,
                    ),
                    if (isCompleted)
                      const Positioned(
                        top: 10,
                        right: 15,
                        child: Icon(Icons.star, color: Colors.yellow, size: 12),
                      )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Text(
                mission.description,
                style: GoogleFonts.notoSansSinhala(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}
