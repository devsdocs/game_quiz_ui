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
  final Map<String, dynamic> id;

  final String question;
  final List<String> incorrectOptions;
  final List<String> reference;
  final String correctOption;
  final String extraContent;
  final String? extraType;
  final bool isUrl;

  Question({
    required this.id,
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
      question: json['question'],
      incorrectOptions: List<String>.from(json['options']['incorrect']),
      correctOption: json['options']['correct'],
      extraContent: json['extra']['content'],
      extraType: json['extra']['type'],
      isUrl: json['options']['is_image'],
      reference: List<String>.from(json['reference']),
    );
  }

  Question copyWith({
    Map<String, dynamic>? id,
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
        question: question ?? this.question,
        incorrectOptions: incorrectOptions ?? this.incorrectOptions,
        reference: reference ?? this.reference,
        correctOption: correctOption ?? this.correctOption,
        extraContent: extraContent ?? this.extraContent,
        extraType: extraType ?? this.extraType,
        isUrl: isUrl ?? this.isUrl);
  }
}
