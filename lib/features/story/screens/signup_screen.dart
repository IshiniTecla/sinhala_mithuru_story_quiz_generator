import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  int _selectedGrade = 1;

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError(
          "කරුණාකර සියලුම විස්තර ඇතුළත් කරන්න."); // Please fill all fields
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Create User
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // 2. Create Profile
        await supabase.from('profiles').insert({
          'id': user.id,
          'name': _nameController.text.trim(),
          'student_grade': _selectedGrade,
          'game_level': 1,
          'xp': 0,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ගිණුම සෑදීම සාර්ථකයි! කරුණාකර ඇතුළත් වන්න.', // Account created! Please login.
                style: GoogleFonts.notoSansSinhala(),
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      _showError("ලියාපදිංචි දෝෂයක්: ${e.message}");
    } catch (e) {
      _showError("කරුණාකර අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කරන්න.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansSinhala(fontSize: 16),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Consistent Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF1EB), // Light Peach start
              Color(0xFFACE0F9), // Light Blue end
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🦁 Header Icon
                const Icon(Icons.person_add_rounded,
                    size: 60, color: Colors.deepPurple),
                const SizedBox(height: 10),

                // 📝 Header Text
                Text(
                  "අලුත් යාලුවෙක්!", // New Friend!
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  "අපි එකතු වෙමු", // Let's Join
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 16,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 30),

                // 📦 Sign Up Form Card (Now Responsive!)
                // 🟢 Added ConstrainedBox here
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Name Input
                        _buildChildFriendlyTextField(
                          controller: _nameController,
                          label: "ඔබේ නම (Name)",
                          icon: Icons.face_rounded,
                        ),
                        const SizedBox(height: 15),

                        // Grade Dropdown (Styled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedGrade,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_circle,
                                  color: Colors.orange),
                              items: [1, 2, 3, 4, 5].map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.school,
                                          color: Colors.orange, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'ශ්‍රේණිය $grade (Grade $grade)',
                                        style: GoogleFonts.notoSansSinhala(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedGrade = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email Input
                        _buildChildFriendlyTextField(
                          controller: _emailController,
                          label: "විද්‍යුත් ලිපිනය (Email)",
                          icon: Icons.email_rounded,
                        ),
                        const SizedBox(height: 15),

                        // Password Input
                        _buildChildFriendlyTextField(
                          controller: _passwordController,
                          label: "මුරපදය (Password)",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 25),

                        // 🚀 Sign Up Button
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.orange)
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'ලියාපදිංචි වන්න', // Sign Up
                                    style: GoogleFonts.notoSansSinhala(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ↩️ Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "ගිණුමක් තිබේද? ", // Already have an account?
                      style: GoogleFonts.notoSansSinhala(
                        color: Colors.deepPurple.shade700,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "ඇතුළත් වන්න", // Login
                          style: GoogleFonts.notoSansSinhala(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      ),
    );
  }

  // Helper Widget for consistent text fields
  Widget _buildChildFriendlyTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.notoSansSinhala(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSansSinhala(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
