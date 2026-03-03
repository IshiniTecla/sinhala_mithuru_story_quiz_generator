import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure you have google_fonts package
import 'signup_screen.dart';
import 'onboarding_screen.dart'; // Check this path matches your project

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Attempt Login
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        if (mounted) {
          // Success! Go to Game Map
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      _showError("ඇතුළත් වීමේ දෝෂයක්: ${e.message}"); // Login Error
    } catch (e) {
      _showError(
          "කරුණාකර අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කරන්න."); // Check Internet
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: GoogleFonts.notoSansSinhala(fontSize: 16),
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Child-Friendly Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFDEE9), // Light Pink/Purple start
              Color(0xFFB5FFFC), // Light Blue end
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🦁 App Logo / Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .school_rounded, // You can replace this with Image.asset('assets/logo.png') later
                    size: 80,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),

                // 📝 App Title in Sinhala
                Text(
                  "සිංහල මිතුරු", // Sinhala Mithuru
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                    shadows: [
                      const Shadow(
                        blurRadius: 2.0,
                        color: Colors.black12,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                Text(
                  "අපි ඉගෙන ගනිමු!", // Let's Learn!
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 18,
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // 📦 Login Card (Now Responsive!)
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
                        // Email Field
                        _buildChildFriendlyTextField(
                          controller: _emailController,
                          label: "විද්‍යුත් ලිපිනය (Email)",
                          icon: Icons.email_rounded,
                        ),
                        const SizedBox(height: 15),

                        // Password Field
                        _buildChildFriendlyTextField(
                          controller: _passwordController,
                          label: "මුරපදය (Password)",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 25),

                        // 🚀 Login Button
                        _isLoading
                            ? Column(
                                children: [
                                  const CircularProgressIndicator(
                                      color: Colors.orange),
                                  const SizedBox(height: 10),
                                  Text(
                                    "මඳක් රැඳී සිටින්න...", // Please wait...
                                    style: GoogleFonts.notoSansSinhala(
                                        color: Colors.grey),
                                  )
                                ],
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'ඇතුළත් වන්න', // Login
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

                // ➕ Sign Up Text
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "ගිණුමක් නැද්ද? ", // Don't have an account?
                      style: GoogleFonts.notoSansSinhala(
                        color: Colors.deepPurple.shade700,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "ලියාපදිංචි වන්න", // Sign Up
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

  // Helper Widget for Text Fields
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
