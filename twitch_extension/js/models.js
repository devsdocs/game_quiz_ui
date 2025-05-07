/**
 * Represents the state of a question in the quiz
 */
class QuestionState {
    constructor({
        selectedOption = null,
        isAnswered = false,
        isCorrect = false
    } = {}) {
        this.selectedOption = selectedOption;
        this.isAnswered = isAnswered;
        this.isCorrect = isCorrect;
    }
}

/**
 * Image sizes for IGDB API
 */
const ImageSize = {
    COVER_SMALL: 'cover_small',
    COVER_SMALL_RETINA: 'cover_small_retina',
    SCREENSHOT_MED: 'screenshot_med',
    SCREENSHOT_MED_RETINA: 'screenshot_med_retina',
    COVER_BIG: 'cover_big',
    COVER_BIG_RETINA: 'cover_big_retina',
    LOG_MED: 'logo_med',
    LOG_MED_RETINA: 'logo_med_retina',
    SCREENSHOT_BIG: 'screenshot_big',
    SCREENSHOT_BIG_RETINA: 'screenshot_big_retina',
    SCREENSHOT_HUGE: 'screenshot_huge',
    SCREENSHOT_HUGE_RETINA: 'screenshot_huge_retina',
    THUMB: 'thumb',
    THUMB_RETINA: 'thumb_retina',
    MICRO: 'micro',
    MICRO_RETINA: 'micro_retina',
    P720: '720p',
    P720_RETINA: '720p_retina',
    P1080: '1080p',
    P1080_RETINA: '1080p_retina',
};

/**
 * Quiz types
 */
const QuizType = {
    MULTIPLE_CHOICE: 'mcq',
    TRUE_FALSE: 'true_false',
    ALL: 'all'
};

/**
 * Parameters for fetching questions
 */
class FetchParams {
    constructor({
        intParam = null,
        stringParam = null,
        isTrending = false
    } = {}) {
        // Either intParam or stringParam, not both
        this.intParam = (intParam !== null && stringParam === null) ? intParam : null;
        this.stringParam = (stringParam !== null && intParam === null) ? stringParam : null;
        this.isTrending = isTrending;
    }

    get isRandom() {
        return this.intParam === null && this.stringParam === null;
    }
}

/**
 * Represents a quiz question
 */
class Question {
    constructor({
        id,
        categoryId,
        question,
        incorrectOptions,
        reference,
        correctOption,
        extraContent,
        extraType = null,
        isUrl
    }) {
        this.id = id;
        this.categoryId = categoryId;
        this.question = question;
        this.incorrectOptions = incorrectOptions;
        this.reference = reference;
        this.correctOption = correctOption;
        this.extraContent = extraContent;
        this.extraType = extraType;
        this.isUrl = isUrl;
    }

    static fromJson(json) {
        return new Question({
            id: json.id,
            categoryId: json.category_id,
            question: json.question,
            incorrectOptions: json.options.incorrect,
            correctOption: json.options.correct,
            extraContent: json.extra.content,
            extraType: json.extra.type,
            isUrl: json.options.is_image,
            reference: json.reference
        });
    }
}
