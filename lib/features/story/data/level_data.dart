import 'package:flutter/material.dart';

// 🟢 1. The Data Model for a Level
class LevelMission {
  final int level;
  final String theme; // The Sinhala theme for the AI
  final String context; // The Sinhala context for the AI
  final Color color;
  final IconData icon;
  final String description;

  LevelMission({
    required this.level,
    required this.theme,
    required this.context,
    required this.color,
    required this.icon,
    required this.description,
  });
}

// 🟢 2. UI Helper: Maps Database Themes to UI Elements
class LevelUIHelper {
  // Locks into your 4 Trained LLaMA Themes
  static ({String sinhalaTheme, Color color, IconData icon}) getThemeData(
      String dbTheme) {
    switch (dbTheme.toLowerCase().trim()) {
      case 'animals':
      case 'සතුන්':
        return (
          sinhalaTheme: "සතුන්",
          color: Colors.green.shade500,
          icon: Icons.pets
        );

      case 'habits':
      case 'යහපුරුදු':
        return (
          sinhalaTheme: "යහපුරුදු",
          color: Colors.teal.shade500,
          icon: Icons.clean_hands_rounded
        );

      case 'trips':
      case 'විනෝද චාරිකා':
        return (
          sinhalaTheme: "විනෝද චාරිකා",
          color: Colors.orange.shade500,
          icon: Icons.directions_bus_rounded
        );

      case 'adventures':
      case 'වීර ක්‍රියා':
        return (
          sinhalaTheme: "වීර ක්‍රියා",
          color: Colors.deepPurple.shade500,
          icon: Icons.explore_rounded
        );

      default:
        // Safe fallback if there's a typo in the database
        return (
          sinhalaTheme: "සතුන්",
          color: Colors.blue.shade400,
          icon: Icons.star_rounded
        );
    }
  }
}
