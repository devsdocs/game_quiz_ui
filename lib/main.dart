import 'package:flutter/material.dart';
import 'package:game_quiz/api.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: QuizBuilder(),
      ),
    );
  }
}

class QuizBuilder extends StatefulWidget {
  const QuizBuilder({super.key});

  @override
  QuizBuilderState createState() => QuizBuilderState();
}

class QuizBuilderState extends State<QuizBuilder> {
  late Future<Map<String, dynamic>> _quizData;

  @override
  void initState() {
    super.initState();
    _quizData = _fetchQuizData();
  }

  // Method to fetch new quiz data
  Future<Map<String, dynamic>> _fetchQuizData() {
    return api.getRandom();
  }

  // Refresh function to re-fetch quiz data
  void _refreshQuiz() {
    setState(() {
      _quizData = _fetchQuizData(); // Re-fetching the future
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Refresh button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _refreshQuiz, // Fetch new quiz data on refresh
            child: const Text('Refresh Questions'),
          ),
        ),
        // Quiz content
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _quizData,
            builder: (b, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (s.hasData) {
                final res = s.data!;
                if (res.isNotEmpty) {
                  if (res['result'] == 'ok') {
                    final data = (res['data'] as List)
                        .map((d) => d as Map<String, dynamic>)
                        .toList();

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (b, i) {
                        return QuizResultWidget(questionData: data[i]);
                      },
                    );
                  }
                }
              } else if (s.hasError) {
                return Center(child: Text('Error loading quiz: ${s.error}'));
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ],
    );
  }
}

class QuizResultWidget extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const QuizResultWidget({required this.questionData, super.key});

  @override
  QuizResultWidgetState createState() => QuizResultWidgetState();
}

class QuizResultWidgetState extends State<QuizResultWidget> {
  String? selectedAnswer;
  bool? isCorrect;
  bool firstLoad = true;
  late List<dynamic> options;

  @override
  Widget build(BuildContext context) {
    final question = widget.questionData['question'];
    final correctAnswer = widget.questionData['option']['answer'];
    final list = [correctAnswer, ...widget.questionData['option']['other']];
    options = firstLoad ? (list..shuffle()) : options;
    final imageUrl = widget.questionData['extra']; // Image URL from 'extra'

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image if the URL is available
            if (imageUrl != null && imageUrl.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  imageUrl.toString(),
                  loadingBuilder: (_, child, loadingProgress) =>
                      const Text('Loading image...'),
                  errorBuilder: (_, error, __) => Text(
                    error.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ),
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Interactive options for True/False or MCQ
            Column(
              children: options.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      firstLoad = false;
                      selectedAnswer = value;
                      // Check if the answer is correct
                      isCorrect = (selectedAnswer == correctAnswer);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Feedback for the user's selection
            if (selectedAnswer != null)
              Text(
                isCorrect == true
                    ? 'Correct!'
                    : 'Incorrect. The correct answer is: $correctAnswer',
                style: TextStyle(
                  color: isCorrect == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
