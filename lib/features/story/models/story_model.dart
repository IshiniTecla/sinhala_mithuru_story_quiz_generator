import 'quiz_model.dart';

class StoryModel {
  final String theme;
  final String title;
  final String originalText;
  final List<String> sentences;
  final String imagePrompt;
  final List<QuizQuestion> quiz;

  StoryModel({
    required this.theme,
    required this.title,
    required this.originalText,
    required this.sentences,
    this.imagePrompt = "",
    this.quiz = const [],
  });

  factory StoryModel.fromJson(Map<String, dynamic> json, String topic) {
    String fullStory = json['story'] ?? "";

    // 🟢 Upgraded Sentence Splitter
    // This splits by '.', '!', or '?' and keeps the punctuation mark attached!
    List<String> splitSentences = fullStory
        .split(RegExp(
            r'(?<=[.!?])\s+')) // Lookbehind regex to split after punctuation + space
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 🟢 Parse Quiz Safely
    List<QuizQuestion> parsedQuiz = [];
    if (json['quiz'] != null && json['quiz'] is List) {
      parsedQuiz = (json['quiz'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    return StoryModel(
      theme: topic,
      title: json['title'] ?? topic, // Default to theme if title is missing
      originalText: fullStory,
      sentences: splitSentences,
      imagePrompt: json['image_prompt'] ?? "$topic cartoon style for kids",
      quiz: parsedQuiz,
    );
  }
}
