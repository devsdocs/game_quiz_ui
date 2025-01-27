import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // QuizType? type,
    // String? session,
    ImageSize? imageSize,
  }) async =>
      (await _get('/quiz/random', {
        // if (type != null) 'type': type.val,
        if (amount != null) 'amount': amount.toString(),
        // if (session != null) 'session': session,
        if (imageSize != null) 'image_size': imageSize.url
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getGameId(
    int gameId, {
    // QuizType? type,
    ImageSize? imageSize,
    // int? limit = 10,
    // int? offset = 0,
    int? amount = 0,
  }) async =>
      (await _get('/quiz/game/$gameId', {
        // if (type != null) 'type': type.val,
        if (amount != null) 'amount': amount.toString(),
        if (imageSize != null) 'image_size': imageSize.url,
        // if (limit != null) 'limit': limit.toString(),
        // if (offset != null) 'offset': offset.toString(),
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

// Riverpod api future provider to get random quiz
final randomQuizProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiProvider);
  return api.getRandom();
});

// Riverpod api future provider to get game id
final gameQuizProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, int gameId) async {
  final api = ref.read(apiProvider);
  return api.getGameId(gameId);
});

final apiProvider = Provider<_Api>((ref) => _Api(ref.read(keyProvider)));

final keyProvider =
    Provider<String>((ref) => ref.read(envProvider)['RAPID_API_KEY']!);

final envProvider =
    Provider<Map<String, String>>((ref) => Platform.environment);

class Question {
  final String id;
  final String categoryId;
  final String question;
  final List<String> incorrectOptions;
  final List<String> reference;
  final String correctOption;
  final String extraContent;
  final String? extraType;
  final bool isUrl;

  Question({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.reference,
    required this.incorrectOptions,
    required this.correctOption,
    required this.extraContent,
    this.extraType,
    required this.isUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      categoryId: json['category_id'],
      question: json['question'],
      incorrectOptions: List<String>.from(json['options']['incorrect']),
      correctOption: json['options']['correct'],
      extraContent: json['extra']['content'],
      extraType: json['extra']['type'],
      isUrl: json['options']['is_url'],
      reference: List<String>.from(json['reference']),
    );
  }
}
