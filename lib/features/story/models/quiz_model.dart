class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // 🟢 1. Safely extract the question (Checking both English and Sinhala keys)
    String qText = json['question'] ??
        json['Q'] ??
        json['ප්‍රශ්නය'] ??
        "ප්‍රශ්නය සොයාගත නොහැක?";

    List<String> parsedOptions = [
      "ඔව්",
      "නැහැ",
      "දන්නේ නැහැ"
    ]; // Generic Fallback
    int correctIdx = 0;

    // 🟢 2. Try to parse as an MCQ (Ideal scenario from LLaMA)
    if (json['options'] != null && json['options'] is List) {
      parsedOptions = List<String>.from(json['options']);
      // Safely parse index even if AI sends it as a string
      correctIdx = int.tryParse(json['correct_answer'].toString()) ?? 0;
    }
    // 🟢 3. Fallback: If AI only returned a single Answer (e.g., {"ප්‍රශ්නය": "...", "පිළිතුර": "..."})
    else {
      String aText = json['answer'] ?? json['A'] ?? json['පිළිතුර'] ?? "";
      if (aText.isNotEmpty) {
        // Artificially create multiple choice options so the UI doesn't break
        parsedOptions = [
          aText, // The real answer
          "වෙනත් පිළිතුරක්", // Fake wrong answer
          "දන්නේ නැහැ" // Fake wrong answer
        ];
        parsedOptions.shuffle(); // Randomize the positions
        correctIdx = parsedOptions
            .indexOf(aText); // Save the position of the real answer
      }
    }

    return QuizQuestion(
      question: qText,
      options: parsedOptions,
      correctAnswerIndex: correctIdx,
    );
  }
}
