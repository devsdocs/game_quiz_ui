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
    ImageSize? imageSize,
  }) async =>
      (await _get('/quiz/random', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
        // if (session != null) 'session': session,
        if (imageSize != null) 'image_size': imageSize.url
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getRandomTrending({
    int amount = 10,
    // QuizType? type,
    // String? session,
    ImageSize? imageSize,
  }) async =>
      (await _get('/quiz/trending', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
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
    int amount = 10,
  }) async =>
      (await _get('/quiz/game/$gameId', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
        if (imageSize != null) 'image_size': imageSize.url,
        // if (limit != null) 'limit': limit.toString(),
        // if (offset != null) 'offset': offset.toString(),
      }))
          .data ??
      {};

  Future<Map<String, dynamic>> getId(
    String id, {
    // QuizType? type,
    ImageSize? imageSize,
    // int? limit = 10,
    // int? offset = 0,
    int amount = 10,
  }) async =>
      (await _get('/quiz/id/$id', {
        // if (type != null) 'type': type.val,
        'amount': amount.toString(),
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
  coverSmallRetina('cover_small_retina'),
  screenshotMed('screenshot_med'),
  screenshotMedRetina('screenshot_med_retina'),
  coverBig('cover_big'),
  coverBigRetina('cover_big_retina'),
  logMed('logo_med'),
  logMedRetina('logo_med_retina'),
  screenshotBig('screenshot_big'),
  screenshotBigRetina('screenshot_big_retina'),
  screenshotHuge('screenshot_huge'),
  screenshotHugeRetina('screenshot_huge_retina'),
  thumb('thumb'),
  thumbRetina('thumb_retina'),
  micro('micro'),
  microRetina('micro_retina'),
  p720('720p'),
  p720Retina('720p_retina'),
  p1080('1080p'),
  p1080Retina('1080p_retina'),
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

class FetchParams {
  final int? intParam;
  final String? stringParam;
  final bool isTrending;

  FetchParams({
    int? intParam,
    String? stringParam,
    this.isTrending = false,
  })  : intParam = (intParam != null && stringParam == null) ? intParam : null,
        stringParam =
            (stringParam != null && intParam == null) ? stringParam : null;

  bool get isRandom => (intParam == null && stringParam == null);

  @override
  String toString() {
    return 'FetchParams{intParam: $intParam, stringParam: $stringParam}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchParams &&
          runtimeType == other.runtimeType &&
          intParam == other.intParam &&
          stringParam == other.stringParam;

  @override
  int get hashCode => intParam.hashCode ^ stringParam.hashCode;
}

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

  Question copyWith({
    String? id,
    String? categoryId,
    String? question,
    List<String>? incorrectOptions,
    List<String>? reference,
    String? correctOption,
    String? extraContent,
    String? extraType,
    bool? isUrl,
  }) {
    return Question(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        question: question ?? this.question,
        incorrectOptions: incorrectOptions ?? this.incorrectOptions,
        reference: reference ?? this.reference,
        correctOption: correctOption ?? this.correctOption,
        extraContent: extraContent ?? this.extraContent,
        extraType: extraType ?? this.extraType,
        isUrl: isUrl ?? this.isUrl);
  }
}
