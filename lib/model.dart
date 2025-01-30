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
