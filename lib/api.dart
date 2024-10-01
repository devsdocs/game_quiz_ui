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
    ImageSize? imageSize,
  }) async =>
      (await _get('/random/${amount ?? 10}', {
        if (type != null) 'type': type.val,
        if (session != null) 'session': session,
        if (imageSize != null) 'image_size': imageSize.url
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getGameId(
    int gameId, {
    QuizType? type,
    ImageSize? imageSize,
    int? limit = 10,
    int? offset = 0,
  }) async =>
      (await _get('/topic/games/$gameId', {
        if (type != null) 'type': type.val,
        if (imageSize != null) 'image_size': imageSize.url,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      }))
          .data ??
      {};
}

/// https://api-docs.igdb.com/#images
enum ImageSize {
  coverSmall('cover_small'),
  screenshotMed('screenshot_med'),
  coverBig('cover_big'),
  logMed('logo_med'),
  screenshotBig('screenshot_big'),
  screenshotHuge('screenshot_huge'),
  thumb('thumb'),
  micro('micro'),
  p720('720p'),
  p1080('1080p'),
  ;

  const ImageSize(this.url);
  final String url;
}

final imageSizesMap =
    ImageSize.values.asMap().map((_, v) => MapEntry(v.url, v));

enum QuizType {
  multipleChoice('mcq'),
  trueFalse('true_false'),
  all('all'),
  ;

  const QuizType(this.val);

  final String val;
}
