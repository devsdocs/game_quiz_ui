import 'dart:io';

import 'package:dio/dio.dart';

final api = _Api(Platform.environment['RAPID_API_KEY']!);

const _base = 'game-quiz.p.rapidapi.com';

final _dio = Dio();

class _Api {
  _Api(this.key);
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

  Future<Map<String, dynamic>> getRandom({
    int? amount,
    QuizType? type,
    String? session,
  }) async =>
      (await _get('/random/${amount ?? 10}', {
        if (type != null) 'type': type.val,
        if (session != null) 'session': session
      }))
          .data ??
      {};
}

enum QuizType {
  multipleChoice('mcq'),
  trueFalse('true_false'),
  all('all'),
  ;

  const QuizType(this.val);

  final String val;
}
