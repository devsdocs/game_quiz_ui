import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_quiz/api.dart';
import 'package:game_quiz/model.dart';
import 'package:game_quiz/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const ProviderScope(
    child: MaterialApp(debugShowCheckedModeBanner: false, home: MainView())));

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Gaming Quiz'),
          centerTitle: true,
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final key = ref.watch(keyProvider);
            if (key.isEmpty) {
              return Center(
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Text('Enter RapidAPI key'),
                              content: TextField(
                                onChanged: (value) {
                                  ref.read(inputTextProvider.notifier).state =
                                      value;
                                },
                                decoration: const InputDecoration(
                                  hintText:
                                      'Your key stays in your device and is never shared.',
                                ),
                                keyboardType: TextInputType.text,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton.icon(
                                  onPressed: () async => await launchUrl(Uri.parse(
                                      'https://rapidapi.com/devsdocs/api/game-quiz')),
                                  label: const Text('Get API Key'),
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(Icons.open_in_new),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final text = ref.read(inputTextProvider);
                                    final api = Api(text);
                                    final test = await api.testKey();

                                    if (!test) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Invalid RapidAPI key'),
                                        ));
                                      }
                                      return;
                                    }
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                    ref.read(keyProvider.notifier).state = text;
                                    ref.invalidate(inputTextProvider);
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Enter API Key'),
                    ),
                  ],
                ),
              );
            }
            return const ApiView();
          },
        ));
  }
}

class ApiView extends StatelessWidget {
  const ApiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Wrap(
        children: [
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                  onPressed: () {
                    ref.invalidate(questionStateProvider);
                    ref.read(fetchParamsProvider.notifier).state =
                        FetchParams();
                    ref.invalidate(quizApiProvider);
                  },
                  child: const Text('Random'));
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                  onPressed: () {
                    ref.invalidate(questionStateProvider);
                    ref.read(fetchParamsProvider.notifier).state =
                        FetchParams(isTrending: true);
                    ref.invalidate(quizApiProvider);
                  },
                  child: const Text('Trending'));
            },
          ),
          TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, child) {
                        return AlertDialog(
                          title: const Text('Enter Question ID or Category ID'),
                          content: TextField(
                            onChanged: (value) {
                              ref.read(inputTextProvider.notifier).state =
                                  value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Question ID or Category ID',
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                ref.invalidate(questionStateProvider);
                                Navigator.of(context).pop();
                                final text = ref.read(inputTextProvider);
                                ref.read(fetchParamsProvider.notifier).state =
                                    FetchParams(stringParam: text);
                                ref.invalidate(inputTextProvider);
                                ref.invalidate(quizApiProvider);
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('ID')),
          TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, child) {
                        return AlertDialog(
                          title: const Text('Enter IGDB Game ID'),
                          content: TextField(
                            onChanged: (value) {
                              ref.read(inputTextProvider.notifier).state =
                                  value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'IGDB Game ID',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                final text = ref.read(inputTextProvider);
                                final tryParse = int.tryParse(text);
                                if (tryParse == null) {
                                  return;
                                }
                                ref.invalidate(questionStateProvider);
                                Navigator.of(context).pop();
                                ref.read(fetchParamsProvider.notifier).state =
                                    FetchParams(intParam: tryParse);
                                ref.invalidate(inputTextProvider);
                                ref.invalidate(quizApiProvider);
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Game ID')),
        ],
      ),
      Expanded(child: Consumer(builder: (context, ref, child) {
        final quiz = ref.watch(quizApiProvider);
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
                  return QuestionCard(
                    question: question,
                    questionIndex: i,
                    options: [
                      ...question.incorrectOptions,
                      question.correctOption,
                    ]..shuffle(ref.watch(randomProvider)),
                  );
                },
              );
            }
            return const Center(child: Text('Error'));
          },
        );
      }))
    ]);
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;
  final List<String> options;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.questionIndex,
  });

  bool _isImageUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
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
              return Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: options.map((option) {
                  final isSelected = questionState.selectedOption == option;
                  final isThisCorrectOption = option == question.correctOption;
                  final isCorrect = questionState.isCorrect;
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
                        color: isDisabled
                            ? isCorrect
                                ? isThisCorrectOption
                                    ? Colors.green
                                    : Colors.white
                                : isThisCorrectOption
                                    ? Colors.green
                                    : isSelected
                                        ? Colors.red
                                        : Colors.white
                            : Colors.white,
                        border: Border.all(
                          color: isDisabled
                              ? isCorrect
                                  ? isThisCorrectOption
                                      ? Colors.green
                                      : Colors.grey
                                  : isThisCorrectOption
                                      ? Colors.green
                                      : isSelected
                                          ? Colors.red
                                          : Colors.grey
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
            Wrap(
              children: [
                TextButton.icon(
                  onPressed: () async =>
                      await launchUrl(Uri.parse(question.reference.first)),
                  icon: const Icon(Icons.open_in_new),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Reference'),
                ),
                TextButton.icon(
                  onPressed: () async =>
                      await Clipboard.setData(ClipboardData(text: question.id)),
                  label: Text('Question ID: ${question.id}'),
                  icon: const Icon(Icons.copy),
                  iconAlignment: IconAlignment.end,
                ),
                TextButton.icon(
                  onPressed: () async => await Clipboard.setData(
                      ClipboardData(text: question.categoryId)),
                  label: Text('Category ID: ${question.categoryId}'),
                  icon: const Icon(Icons.copy),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
