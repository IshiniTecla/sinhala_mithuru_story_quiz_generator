import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  // 🟢 FIX: Use a 'getter' to avoid "Supabase not initialized" error
  static SupabaseClient get _supabase => Supabase.instance.client;

  static const String _localUserKey = 'current_user_data';

  // 🟢 1. LOGIN / SIGN UP
  // Returns TRUE if login successful, FALSE if error
  static Future<bool> loginOrSignup(String name, [int? grade]) async {
    final cleanName = name.trim();

    try {
      // A. CHECK IF USER EXISTS
      final existingData = await _supabase
          .from('profiles')
          .select()
          .eq('name', cleanName)
          .maybeSingle();

      Map<String, dynamic> userData;

      if (existingData != null) {
        // ✅ USER FOUND (Login)
        userData = existingData;
        print("✅ Logged in as existing user: ${userData['name']}");
      } else {
        // 🆕 NEW USER (Sign Up)
        if (grade == null) return false; // Need grade to create account!

        // Create row in Supabase and return the new data immediately
        final newData = await _supabase
            .from('profiles')
            .insert({
              'name': cleanName,
              'student_grade': grade,
              'game_level': 1,
              'xp': 0,
            })
            .select()
            .single();

        userData = newData;
        print("🆕 Created new account: ${userData['name']}");
      }

      // B. SAVE SESSION TO PHONE
      // Map database keys (snake_case) to Model keys (camelCase)
      UserModel user = UserModel(
        id: userData['id'], // 🟢 The Supabase UUID
        name: userData['name'],
        studentGrade: userData['student_grade'],
        gameLevel: userData['game_level'],
        xp: userData['xp'],
      );

      await _saveLocalUser(user);
      return true;
    } catch (e) {
      print("❌ Auth Error: $e");
      return false;
    }
  }

  // 🟢 2. GET CURRENT LOGGED IN STUDENT
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_localUserKey);
    if (jsonStr == null) return null;

    return UserModel.fromJson(jsonDecode(jsonStr));
  }

  // 🟢 3. SAVE PROGRESS (Using ID)
  static Future<void> updateProgress(int newLevel, int newXP) async {
    UserModel? user = await getUser();
    if (user == null) return;

    try {
      // Update Supabase using the ID (Safe & Accurate)
      await _supabase.from('profiles').update({
        'game_level': newLevel,
        'xp': newXP,
      }).eq('id', user.id);

      // Update Local Data too (so UI updates instantly)
      UserModel updatedUser = UserModel(
          id: user.id,
          name: user.name,
          studentGrade: user.studentGrade,
          gameLevel: newLevel,
          xp: newXP);
      await _saveLocalUser(updatedUser);

      print("☁️ Saved to Cloud: Level $newLevel, XP $newXP");
    } catch (e) {
      print("❌ Save Error: $e");
    }
  }

  // Helper to save locally
  static Future<void> _saveLocalUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUserKey, jsonEncode(user.toJson()));
  }

  // 🟢 4. LOGOUT (Optional)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
