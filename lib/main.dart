import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your Onboarding Screen (Update this path if your onboarding screen is in a different folder)
import 'features/story/screens/onboarding_screen.dart';

// Keeping these commented out so you don't lose them for later
// import 'features/story/services/auth_service.dart';
// import 'features/story/models/user_model.dart';
// import 'features/story/screens/level_map_screen.dart';
// import 'features/story/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 1. START SUPABASE
  // We keep this running so your mock database calls/Score Screen don't crash
  await Supabase.initialize(
    url: 'https://amwimxdgrdnrpfemgfwm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtd2lteGRncmRucnBmZW1nZndtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyMTM5NTYsImV4cCI6MjA4Njc4OTk1Nn0.OVoiWmIsCRT5Z8zucSgj6zGs48tZI04XZlb6xV4i-l8',
  );

  // 🟢 2. TEMPORARILY DISABLED AUTH CHECK FOR TESTING
  /*
  final session = Supabase.instance.client.auth.currentSession;
  UserModel? user;

  if (session != null) {
    user = await AuthService.getUser();
  }

  Widget startScreen;

  if (user != null) {
    print("🚀 Welcome back, ${user.name}! Loading Level ${user.gameLevel}...");
    startScreen = const LevelMapScreen();
  } else {
    print("🆕 No User found. Showing Login Screen.");
    startScreen = const LoginScreen(); 
  }
  */

  // 🟢 3. FORCE START AT ONBOARDING SCREEN
  Widget startScreen = const OnboardingScreen();

  runApp(SinhalaMithuruApp(startScreen: startScreen));
}

class SinhalaMithuruApp extends StatelessWidget {
  final Widget startScreen;

  const SinhalaMithuruApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinhala Mithuru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansSinhalaTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: startScreen, // This will now always be the Onboarding Screen
    );
  }
}
