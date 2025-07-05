import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/quiz_model.dart';
import '../../../utils/constants/colors.dart';

class QuizScreen extends StatefulWidget {
  final String category;


  const QuizScreen({
    super.key,
    required this.category,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int totalScore = 0;
  bool quizCompleted = false;
  late Future<Quiz> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = _fetchQuizFromFirestore();
  }

  Future<Quiz> _fetchQuizFromFirestore() async {
    print('🟡 Starting to fetch quiz for category: ${widget.category}');

    try {
      final quizCollection = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.category)
          .collection('quizzes')
          .get();

      final allDocs = quizCollection.docs;

      if (allDocs.isEmpty) {
        throw Exception('No quizzes found in category ${widget.category}');
      }

      // Pick one at random
      final randomDoc = (allDocs..shuffle()).first;
      final data = randomDoc.data();
      print('🎯 Picked random quiz ID: ${randomDoc.id}');
      print('📄 Raw Firestore data: $data');

      // Validation
      if (data['questions'] == null ||
          data['category'] == null ||
          data['isPersonalityBased'] == null) {
        print('🔴 Error: Missing required fields in quiz data');
        print('Found fields: ${data.keys.join(', ')}');
        throw Exception('Invalid quiz format');
      }

      // Convert questions
      final questions = (data['questions'] as List).map((q) {
        if (q is! Map<String, dynamic> ||
            q['answers'] == null ||
            (q['question'] == null && q['questionText'] == null)) {
          throw Exception('Invalid question format');
        }

        final answers = (q['answers'] as List).map((a) {
          if (a is! Map<String, dynamic> ||
              a['text'] == null ||
              a['score'] == null) {
            throw Exception('Invalid answer format');
          }

          return QuizAnswer(
            text: a['text'],
            score: a['score'],
            isCorrect: a['isCorrect'] ?? false,
          );
        }).toList();

        return QuizQuestion(
          question: q['question'] ?? q['questionText'],
          answers: answers,
        );
      }).toList();

      if (questions.isEmpty) {
        throw Exception('Quiz contains no valid questions');
      }

      final quiz = Quiz(
        category: data['category'],
        isPersonalityBased: data['isPersonalityBased'],
        questions: questions,
      );

      print('🎉 Successfully created Quiz object: ${quiz.questions.length} questions');
      return quiz;
    } catch (e) {
      print('🔴 Error in _fetchQuizFromFirestore: $e');
      rethrow;
    }
  }


  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: _buildAppBar('Loading...'),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      appBar: _buildAppBar('Error'),
      body: Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  // Add the required build method
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quiz>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }

        final quiz = snapshot.data!;

        // Add validation for empty questions
        if (quiz.questions.isEmpty) {
          return _buildErrorScreen('No questions found in this quiz');
        }

        if (quizCompleted) {
          return _buildResultsScreen(quiz);
        }

        return _buildQuizScreen(quiz);
      },
    );
  }


  Widget _buildQuizScreen(Quiz quiz) {
    final currentQuestion = quiz.questions[currentQuestionIndex];
    return Scaffold(
      appBar: _buildAppBar('${quiz.category} Quiz'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / quiz.questions.length,
              color: MyColors.color2,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ..._buildAnswerButtons(currentQuestion, quiz.isPersonalityBased),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerButtons(QuizQuestion question, bool isPersonalityBased) {
    return question.answers.map((answer) => GestureDetector(
      onTap: () => _onAnswerSelected(answer, isPersonalityBased, question.answers.length),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MyColors.color2, width: 2),
        ),
        child: Center(
          child: Text(
            answer.text,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.color2
            ),
          ),
        ),
      ),
    )).toList();
  }

  void _onAnswerSelected(QuizAnswer answer, bool isPersonalityBased, int totalQuestions) {
    setState(() {
      if (isPersonalityBased) {
        totalScore += answer.score;
      } else if (answer.isCorrect) {
        totalScore += 1;
      }

      if (currentQuestionIndex + 1 < totalQuestions) {
        currentQuestionIndex++;
      } else {
        quizCompleted = true;
      }
    });
  }

  Widget _buildResultsScreen(Quiz quiz) {
    return Scaffold(
      appBar: _buildAppBar('${quiz.category} Quiz Results'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: MyColors.color2),
              const SizedBox(height: 20),
              Text(
                _getResultMessage(quiz),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 1,color: Colors.black54,), borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: const Text(
                      "Disclaimer:\n\n"
                          "This quiz is intended for informational and self-reflection purposes only. "
                          "It is not a diagnostic tool and should not replace professional mental health advice or assessment. "
                          "If you find the results concerning or emotionally distressing, we encourage you to reach out to our mental health specialist "
                          "through the Luminara app to further explore and process your experience.",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyColors.color1, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Text(
                    "Back to Quizzes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.color1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _getResultMessage(Quiz quiz) {
    if (quiz.isPersonalityBased) {
      return _getPersonalityResult(quiz);
    }
    return 'You scored $totalScore out of ${quiz.questions.length}';
  }

  String _getPersonalityResult(Quiz quiz) {
    final maxScore = quiz.questions.length * 3;
    final percentage = (totalScore / maxScore) * 100;

    if (percentage >= 75) {
      return "🌿\nExcellent! You've shown great mastery in this area!";
    } else if (percentage >= 50) {
      return "✨\nGood job! There's still room for improvement.";
    } else {
      return "⏳\nKeep practicing! Consider exploring our resources to improve.";
    }
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      toolbarHeight: 65,
      flexibleSpace: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8F8F8),
                  const Color(0xFFF1F1F1),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.orangeAccent,
                    Colors.green,
                    Colors.greenAccent,
                  ],
                  stops: const [0.0, 0.5, 0.5, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(title),
    );
  }
}