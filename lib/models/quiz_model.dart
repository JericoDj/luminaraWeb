class Quiz {
  final String category;
  final bool isPersonalityBased;
  final List<QuizQuestion> questions;

  Quiz({
    required this.category,
    required this.isPersonalityBased,
    required this.questions,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data) {
    return Quiz(
      category: data['category'] ?? 'Uncategorized',
      isPersonalityBased: data['isPersonalityBased'] ?? false,
      questions: (data['questions'] as List<dynamic>)
          .map((q) => QuizQuestion.fromMap(q))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<QuizAnswer> answers;

  QuizQuestion({required this.question, required this.answers});

  factory QuizQuestion.fromMap(Map<String, dynamic> data) {
    return QuizQuestion(
      question: data['question'] ?? '',
      answers: (data['answers'] as List<dynamic>)
          .map((a) => QuizAnswer.fromMap(a))
          .toList(),
    );
  }
}

class QuizAnswer {
  final String text;
  final int score;
  final bool isCorrect;

  QuizAnswer({
    required this.text,
    this.score = 0,
    this.isCorrect = false,
  });

  factory QuizAnswer.fromMap(Map<String, dynamic> data) {
    return QuizAnswer(
      text: data['text'] ?? '',
      score: data['score'] ?? 0,
      isCorrect: data['isCorrect'] ?? false,
    );
  }
}