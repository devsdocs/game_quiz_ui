import 'package:dio/dio.dart';

const _base = 'game-quiz.p.rapidapi.com';

final _dio = Dio();

class Api {
  Api(this.key);
  final String key;

  Future<Response<Map<String, dynamic>>> _get(String path,
          [Map<String, String>? params]) async =>
      await _dio.getUri<Map<String, dynamic>>(
        Uri.https(_base, path, params),
        options: Options(
          headers: {
            'X-RapidAPI-Key': key,
            'X-RapidAPI-Host': _base,
          },
        ),
      );

  Future<bool> testKey() async {
    try {
      await getRandom(amount: 1);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getRandom({
    int amount = 10,
    // QuizType? type,
    // String? session,
  }) async =>
      (await _get('/quiz/random', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
        // if (session != null) 'session': session,
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getRandomTrending({
    int amount = 10,
    // QuizType? type,
    // String? session,
  }) async =>
      (await _get('/quiz/trending', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
        // if (session != null) 'session': session,
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getGameId(
    int gameId, {
    // QuizType? type,

    // int? limit = 10,
    // int? offset = 0,
    int amount = 10,
  }) async =>
      (await _get('/quiz/game/$gameId', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
        // if (limit != null) 'limit': limit.toString(),
        // if (offset != null) 'offset': offset.toString(),
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getId(
    String id, {
    // QuizType? type,

    // int? limit = 10,
    // int? offset = 0,
    int amount = 10,
  }) async =>
      (await _get('/quiz/id/$id', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),

        // if (limit != null) 'limit': limit.toString(),
        // if (offset != null) 'offset': offset.toString(),
      }))
          .data ??
      {};
}
