import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_quiz/api.dart';
import 'package:game_quiz/main.dart';

final inputTextProvider = StateProvider<String>((ref) => '');

// State provider to manage the question states
final questionStateProvider =
    StateNotifierProvider.family<QuestionStateNotifier, QuestionState, int>(
        (ref, index) => QuestionStateNotifier());

final quizApiProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiProvider);
  final params = ref.watch(fetchParamsProvider);

  if (params.isRandom) {
    return api.getRandom();
  }

  if (params.stringParam != null) {
    return api.getId(params.stringParam!);
  }

  return api.getGameId(params.intParam!);
});

final fetchParamsProvider = StateProvider<FetchParams>((ref) {
  return FetchParams();
});

final apiProvider = Provider<Api>((ref) => Api(ref.read(keyProvider)));

final keyProvider = StateProvider<String>((ref) => '');
