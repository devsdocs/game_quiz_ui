import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_quiz/api.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const ProviderScope(
    child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp())));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Column(children: [
        Consumer(
          builder: (context, ref, child) {
            return TextButton(
                onPressed: () => ref.invalidate(randomQuizProvider),
                child: const Text('Refresh'));
          },
        ),
        Expanded(child: Consumer(builder: (context, ref, child) {
          final quiz = ref.watch(randomQuizProvider);
          return quiz.when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            data: (result) {
              if (result['status'] == 'ok') {
                final data = result['data'] as List<dynamic>;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final question = Question.fromJson(data[i]);
                    return QuestionCard(question: question, questionIndex: i);
                  },
                );
              }
              return const Center(child: Text('Error'));
            },
          );
        }))
      ]),
    );
  }
}

// State provider to manage the question states
final questionStateProvider =
    StateNotifierProvider.family<QuestionStateNotifier, QuestionState, int>(
        (ref, index) => QuestionStateNotifier());

class QuestionState {
  final String? selectedOption;
  final bool isAnswered;
  final bool isCorrect;

  QuestionState({
    this.selectedOption,
    this.isAnswered = false,
    this.isCorrect = false,
  });

  QuestionState copyWith({
    String? selectedOption,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return QuestionState(
      selectedOption: selectedOption ?? this.selectedOption,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class QuestionStateNotifier extends StateNotifier<QuestionState> {
  QuestionStateNotifier() : super(QuestionState());

  void selectOption(String option, String correctOption) {
    if (!state.isAnswered) {
      final isCorrect = option == correctOption;
      state = state.copyWith(
        selectedOption: option,
        isAnswered: true,
        isCorrect: isCorrect,
      );
    }
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
  });

  bool _isImageUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      ...question.incorrectOptions,
      question.correctOption,
    ]..shuffle();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (question.extraType == 'image_url')
              CachedNetworkImage(
                imageUrl: question.extraContent,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  height: 250,
                  width: 250,
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.scaleDown,
                height: 250,
              )
            else
              Text(question.extraContent),
            const SizedBox(height: 10),
            Consumer(builder: (context, ref, child) {
              final questionState =
                  ref.watch(questionStateProvider(questionIndex));
              final questionNotifier =
                  ref.read(questionStateProvider(questionIndex).notifier);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((option) {
                  final isSelected = questionState.selectedOption == option;
                  final isCorrect = questionState.isCorrect && isSelected;
                  final isDisabled = questionState.isAnswered;

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () => questionNotifier.selectOption(
                            option, question.correctOption),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _isImageUrl(option)
                          ? CachedNetworkImage(
                              imageUrl: option,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => SizedBox(
                                height: 150,
                                width: 150,
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              height: 150,
                            )
                          : Text(
                              option,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async =>
                  await launchUrl(Uri.parse(question.reference.first)),
              child: const Text('Reference'),
            ),
          ],
        ),
      ),
    );
  }
}
