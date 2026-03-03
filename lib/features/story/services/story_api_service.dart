import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_model.dart';

class StoryApiService {
  // 🟢 1. UPDATED TO V7 URL
  static const String baseUrl =
      'https://teclaishini442--sinhala-mithuru-backend-v7-fastapi-app.modal.run';

  // 🟢 2. THE CACHE MAPS (Stores previous generations in memory)
  static final Map<String, String> _storyCache = {};
  static final Map<String, List<QuizQuestion>> _quizCache = {};

  static Future<String> generateStory({
    required int grade,
    required String theme,
    required String contextText,
  }) async {
    // 🟢 3. CACHE CHECK: Create a unique key for this exact request
    final String cacheKey = '${grade}_${theme}_${contextText}';

    // If we already generated this exact story, return it instantly!
    if (_storyCache.containsKey(cacheKey)) {
      print("⚡ FAST LOAD: Returning STORY from local Cache!");
      return _storyCache[cacheKey]!;
    }

    final String levelStr = grade <= 2 ? "සරල" : "උසස්";

    print("☁️ API CALL: Generating new story from Modal Backend...");
    final response = await http
        .post(
          Uri.parse('$baseUrl/generate_story'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'level': levelStr,
            'theme': theme,
            'context': contextText,
          }),
        )
        // INCREASED TIMEOUT TO 180s TO ALLOW FOR MODAL GPU COLD STARTS
        .timeout(const Duration(seconds: 180));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final String generatedStory = decoded['story'] as String;

      // 🟢 4. SAVE TO CACHE: Save the result so we never have to fetch it again
      _storyCache[cacheKey] = generatedStory;

      return generatedStory;
    } else {
      throw Exception(
          'Failed to generate story. Status: ${response.statusCode}');
    }
  }

  static Future<List<QuizQuestion>> generateQuiz({
    required String storyText,
    required int grade,
  }) async {
    // 🟢 5. CACHE CHECK FOR QUIZZES
    final String cacheKey =
        '${grade}_${storyText.hashCode}'; // Using hash to keep key short

    if (_quizCache.containsKey(cacheKey)) {
      print("⚡ FAST LOAD: Returning QUIZ from local Cache!");
      return _quizCache[cacheKey]!;
    }

    final String levelStr = grade <= 2 ? "සරල" : "උසස්";

    print("☁️ API CALL: Generating new quiz from Modal Backend...");
    final response = await http
        .post(
          Uri.parse('$baseUrl/generate_quiz'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'story': storyText,
            'level': levelStr,
          }),
        )
        // INCREASED TIMEOUT HERE TOO
        .timeout(const Duration(seconds: 180));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic>? quizList = decoded['quiz'];

      List<QuizQuestion> finalQuizList;

      // ULTIMATE FALLBACK: If the AI failed to generate questions
      if (quizList == null || quizList.isEmpty) {
        finalQuizList = [
          QuizQuestion(
            question: "කතාව හොඳින් කියෙව්වාද?",
            options: ["ඔව්", "නැහැ", "මතක නැහැ"],
            correctAnswerIndex: 0,
          )
        ];
      } else {
        finalQuizList = quizList.map((q) => QuizQuestion.fromJson(q)).toList();
      }

      // 🟢 6. SAVE TO CACHE
      _quizCache[cacheKey] = finalQuizList;

      return finalQuizList;
    } else {
      throw Exception(
          'Failed to generate quiz. Status: ${response.statusCode}');
    }
  }

  // Optional: A helper method to clear the cache if you ever need to force a refresh (like on logout)
  static void clearCache() {
    _storyCache.clear();
    _quizCache.clear();
    print("🧹 Story and Quiz Cache cleared!");
  }
}
