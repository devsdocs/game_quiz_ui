/**
 * Gaming Quiz Twitch Extension
 */
(function() {
    // State
    let apiKey = '';
    let api = null;
    let currentFetchParams = new FetchParams();
    let questionStates = [];
    let questionsData = [];
    
    // Elements
    const apiKeySection = document.getElementById('api-key-section');
    const quizControls = document.getElementById('quiz-controls');
    const questionsContainer = document.getElementById('questions-container');
    const loadingElement = document.getElementById('loading');
    const errorMessage = document.getElementById('error-message');
    
    // Modals
    const apiKeyModal = document.getElementById('api-key-modal');
    const idModal = document.getElementById('id-modal');
    const gameIdModal = document.getElementById('game-id-modal');
    
    // Buttons
    const enterApiKeyBtn = document.getElementById('enter-api-key');
    const getApiKeyBtn = document.getElementById('get-api-key');
    const submitApiKeyBtn = document.getElementById('submit-api-key');
    const randomBtn = document.getElementById('random');
    const trendingBtn = document.getElementById('trending');
    const byIdBtn = document.getElementById('by-id');
    const byGameIdBtn = document.getElementById('by-game-id');
    const submitIdBtn = document.getElementById('submit-id');
    const submitGameIdBtn = document.getElementById('submit-game-id');
    
    // Inputs
    const apiKeyInput = document.getElementById('api-key-input');
    const idInput = document.getElementById('id-input');
    const gameIdInput = document.getElementById('game-id-input');
    
    /**
     * Initialize the app
     */
    function init() {
        // Check for saved API key
        const savedKey = localStorage.getItem('game_quiz_api_key');
        if (savedKey) {
            apiKey = savedKey;
            api = new Api(apiKey);
            showQuizControls();
        }
        
        // Set up event listeners
        enterApiKeyBtn.addEventListener('click', showApiKeyModal);
        getApiKeyBtn.addEventListener('click', () => {
            window.open('https://rapidapi.com/devsdocs/api/game-quiz', '_blank');
        });
        submitApiKeyBtn.addEventListener('click', handleApiKeySubmission);
        
        randomBtn.addEventListener('click', fetchRandomQuestions);
        trendingBtn.addEventListener('click', fetchTrendingQuestions);
        byIdBtn.addEventListener('click', () => showModal(idModal));
        byGameIdBtn.addEventListener('click', () => showModal(gameIdModal));
        
        submitIdBtn.addEventListener('click', handleIdSubmission);
        submitGameIdBtn.addEventListener('click', handleGameIdSubmission);
        
        // Initialize Twitch Extension
        Twitch.ext.onAuthorized(function(auth) {
            // Extension is initialized, we can use Twitch features if needed
            console.log('Twitch Extension Initialized', auth);
        });
    }
    
    /**
     * Show API key modal
     */
    function showApiKeyModal() {
        showModal(apiKeyModal);
    }
    
    /**
     * Show a modal
     * @param {HTMLElement} modal - The modal to show
     */
    function showModal(modal) {
        modal.classList.remove('hidden');
    }
    
    /**
     * Hide a modal
     * @param {HTMLElement} modal - The modal to hide
     */
    function hideModal(modal) {
        modal.classList.add('hidden');
    }
    
    /**
     * Handle API key submission
     */
    async function handleApiKeySubmission() {
        const key = apiKeyInput.value.trim();
        
        if (!key) {
            showError('Empty field');
            return;
        }
        
        if (key.length !== 50) {
            showError('Invalid key length');
            return;
        }
        
        showLoading();
        
        try {
            api = new Api(key);
            const isValid = await api.testKey();
            
            if (!isValid) {
                showError('Invalid RapidAPI key');
                hideLoading();
                return;
            }
            
            // Save the key and update the UI
            apiKey = key;
            localStorage.setItem('game_quiz_api_key', key);
            hideModal(apiKeyModal);
            showQuizControls();
            hideLoading();
            
            // Clear input
            apiKeyInput.value = '';
        } catch (error) {
            showError('Error validating API key: ' + error.message);
            hideLoading();
        }
    }
    
    /**
     * Handle ID submission
     */
    function handleIdSubmission() {
        const id = idInput.value.trim();
        
        if (!id) {
            showError('Please enter an ID');
            return;
        }
        
        hideModal(idModal);
        
        // Clear states and fetch with the new ID
        questionStates = [];
        currentFetchParams = new FetchParams({ stringParam: id });
        fetchQuestions();
        
        // Clear input
        idInput.value = '';
    }
    
    /**
     * Handle Game ID submission
     */
    function handleGameIdSubmission() {
        const gameId = parseInt(gameIdInput.value.trim());
        
        if (isNaN(gameId)) {
            showError('Please enter a valid game ID');
            return;
        }
        
        hideModal(gameIdModal);
        
        // Clear states and fetch with the new game ID
        questionStates = [];
        currentFetchParams = new FetchParams({ intParam: gameId });
        fetchQuestions();
        
        // Clear input
        gameIdInput.value = '';
    }
    
    /**
     * Show the quiz controls
     */
    function showQuizControls() {
        apiKeySection.classList.add('hidden');
        quizControls.classList.remove('hidden');
        questionsContainer.classList.remove('hidden');
    }
    
    /**
     * Fetch random questions
     */
    function fetchRandomQuestions() {
        questionStates = [];
        currentFetchParams = new FetchParams();
        fetchQuestions();
    }
    
    /**
     * Fetch trending questions
     */
    function fetchTrendingQuestions() {
        questionStates = [];
        currentFetchParams = new FetchParams({ isTrending: true });
        fetchQuestions();
    }
    
    /**
     * Fetch questions based on current parameters
     */
    async function fetchQuestions() {
        if (!api) return;
        
        showLoading();
        questionsContainer.innerHTML = '';
        
        try {
            let result;
            
            if (currentFetchParams.isRandom) {
                if (currentFetchParams.isTrending) {
                    result = await api.getRandomTrending();
                } else {
                    result = await api.getRandom();
                }
            } else if (currentFetchParams.stringParam) {
                result = await api.getId(currentFetchParams.stringParam);
            } else if (currentFetchParams.intParam) {
                result = await api.getGameId(currentFetchParams.intParam);
            }
            
            if (result && result.status === 'ok') {
                questionsData = result.data;
                // Initialize question states
                questionStates = new Array(questionsData.length).fill(null).map(() => new QuestionState());
                renderQuestions(questionsData);
            } else {
                showError('Failed to fetch questions');
            }
        } catch (error) {
            showError('Error: ' + error.message);
        } finally {
            hideLoading();
        }
    }
    
    /**
     * Render questions to the UI
     * @param {Array} questions - Array of question data
     */
    function renderQuestions(questions) {
        questionsContainer.innerHTML = '';
        
        questions.forEach((questionData, index) => {
            const question = Question.fromJson(questionData);
            
            // Create options array and shuffle
            const options = [...question.incorrectOptions, question.correctOption];
            shuffleArray(options);
            
            const questionElement = document.createElement('div');
            questionElement.className = 'question-card';
            
            // Question text
            const questionText = document.createElement('div');
            questionText.className = 'question-text';
            questionText.textContent = question.question;
            questionElement.appendChild(questionText);
            
            // Extra content (image or game info)
            if (question.extraType === 'image_id') {
                const extraImage = document.createElement('img');
                extraImage.className = 'extra-image';
                extraImage.src = `https://images.igdb.com/igdb/image/upload/t_1080p_2x/${question.extraContent}.webp`;
                extraImage.alt = 'Game Image';
                questionElement.appendChild(extraImage);
            } else {
                const gameInfo = document.createElement('div');
                gameInfo.className = 'game-info';
                gameInfo.textContent = `Game: ${question.extraContent}`;
                questionElement.appendChild(gameInfo);
            }
            
            // Options
            const optionsContainer = document.createElement('div');
            optionsContainer.className = 'options-container';
            
            options.forEach(option => {
                const optionElement = document.createElement('div');
                optionElement.className = 'option';
                optionElement.dataset.option = option;
                
                if (question.isUrl) {
                    const optionImage = document.createElement('img');
                    optionImage.className = 'option-image';
                    optionImage.src = `https://images.igdb.com/igdb/image/upload/t_1080p_2x/${option}.webp`;
                    optionImage.alt = 'Option Image';
                    optionElement.appendChild(optionImage);
                } else {
                    optionElement.textContent = option;
                }
                
                // Add click handler
                optionElement.addEventListener('click', () => {
                    handleOptionSelection(index, option, question.correctOption);
                });
                
                optionsContainer.appendChild(optionElement);
            });
            
            questionElement.appendChild(optionsContainer);
            
            // Question footer (reference and IDs)
            const footer = document.createElement('div');
            footer.className = 'question-footer';
            
            // Reference link
            const referenceLink = document.createElement('div');
            referenceLink.className = 'reference-link';
            referenceLink.innerHTML = '<i class="icon-external-link"></i> Reference';
            referenceLink.addEventListener('click', () => {
                window.open(question.reference[0], '_blank');
            });
            footer.appendChild(referenceLink);
            
            // Question ID
            const questionId = document.createElement('div');
            questionId.className = 'id-info';
            questionId.textContent = `Question ID: ${question.id}`;
            questionId.addEventListener('click', () => {
                copyToClipboard(question.id);
                showMessage('Question ID copied to clipboard');
            });
            footer.appendChild(questionId);
            
            // Category ID
            const categoryId = document.createElement('div');
            categoryId.className = 'id-info';
            categoryId.textContent = `Category ID: ${question.categoryId}`;
            categoryId.addEventListener('click', () => {
                copyToClipboard(question.categoryId);
                showMessage('Category ID copied to clipboard');
            });
            footer.appendChild(categoryId);
            
            questionElement.appendChild(footer);
            
            // Add the question to the container
            questionsContainer.appendChild(questionElement);
        });
    }
    
    /**
     * Handle option selection
     * @param {number} questionIndex - Index of the question
     * @param {string} selectedOption - The selected option
     * @param {string} correctOption - The correct option
     */
    function handleOptionSelection(questionIndex, selectedOption, correctOption) {
        // If already answered, do nothing
        if (questionStates[questionIndex].isAnswered) {
            return;
        }
        
        const isCorrect = selectedOption === correctOption;
        
        // Update state
        questionStates[questionIndex] = new QuestionState({
            selectedOption: selectedOption,
            isAnswered: true,
            isCorrect: isCorrect
        });
        
        // Update UI
        const questionCard = questionsContainer.children[questionIndex];
        const options = questionCard.querySelectorAll('.option');
        
        options.forEach(option => {
            const optionValue = option.dataset.option;
            
            if (optionValue === selectedOption) {
                option.classList.add('selected');
                option.classList.add(isCorrect ? 'correct' : 'incorrect');
            } else if (optionValue === correctOption) {
                option.classList.add('correct');
            }
        });
    }
    
    /**
     * Show loading indicator
     */
    function showLoading() {
        loadingElement.classList.remove('hidden');
        errorMessage.classList.add('hidden');
    }
    
    /**
     * Hide loading indicator
     */
    function hideLoading() {
        loadingElement.classList.add('hidden');
    }
    
    /**
     * Show error message
     * @param {string} message - The error message
     */
    function showError(message) {
        errorMessage.classList.remove('hidden');
        errorMessage.querySelector('p').textContent = message;
        
        // Auto-hide after 3 seconds
        setTimeout(() => {
            errorMessage.classList.add('hidden');
        }, 3000);
    }
    
    /**
     * Show message
     * @param {string} message - The message to show
     */
    function showMessage(message) {
        // Reuse error message element for normal messages
        errorMessage.classList.remove('hidden');
        errorMessage.querySelector('p').textContent = message;
        
        // Auto-hide after 3 seconds
        setTimeout(() => {
            errorMessage.classList.add('hidden');
        }, 3000);
    }
    
    /**
     * Copy text to clipboard
     * @param {string} text - The text to copy
     */
    function copyToClipboard(text) {
        navigator.clipboard.writeText(text).catch(err => {
            console.error('Could not copy text: ', err);
        });
    }
    
    /**
     * Shuffle an array in-place using Fisher-Yates algorithm
     * @param {Array} array - The array to shuffle
     */
    function shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
    }
    
    // Initialize when DOM is ready
    document.addEventListener('DOMContentLoaded', init);
})();
