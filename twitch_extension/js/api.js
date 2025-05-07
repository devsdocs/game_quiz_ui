/**
 * API client for the Game Quiz API
 */
class Api {
    constructor(key) {
        this.key = key;
        this.baseUrl = 'https://game-quiz.p.rapidapi.com';
    }

    /**
     * Make a GET request to the API
     * @param {string} path - The endpoint path
     * @param {Object} params - URL parameters
     * @returns {Promise<Object>} The response data
     */
    async _get(path, params = {}) {
        const url = new URL(`${this.baseUrl}${path}`);
        
        // Add query parameters
        Object.keys(params).forEach(key => {
            if (params[key] !== null && params[key] !== undefined) {
                url.searchParams.append(key, params[key]);
            }
        });

        try {
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'X-RapidAPI-Key': this.key,
                    'X-RapidAPI-Host': 'game-quiz.p.rapidapi.com'
                }
            });

            if (!response.ok) {
                throw new Error(`API Error: ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            console.error('API Request Error:', error);
            throw error;
        }
    }

    /**
     * Test if the API key is valid
     * @returns {Promise<boolean>} Whether the key is valid
     */
    async testKey() {
        try {
            await this.getRandom(1);
            return true;
        } catch (error) {
            return false;
        }
    }

    /**
     * Get random questions
     * @param {number} amount - Number of questions to fetch
     * @returns {Promise<Object>} The response data
     */
    async getRandom(amount = 10) {
        return await this._get('/quiz/random', {
            amount: amount.toString(),
            refresh: 'true'
        });
    }

    /**
     * Get trending questions
     * @param {number} amount - Number of questions to fetch
     * @returns {Promise<Object>} The response data
     */
    async getRandomTrending(amount = 10) {
        return await this._get('/quiz/trending', {
            amount: amount.toString(),
            refresh: 'true'
        });
    }

    /**
     * Get questions for a specific game ID
     * @param {number} gameId - The IGDB game ID
     * @param {number} amount - Number of questions to fetch
     * @returns {Promise<Object>} The response data
     */
    async getGameId(gameId, amount = 10) {
        return await this._get(`/quiz/game/${gameId}`, {
            amount: amount.toString(),
            refresh: 'true'
        });
    }

    /**
     * Get questions for a specific ID (question or category)
     * @param {string} id - The question or category ID
     * @param {number} amount - Number of questions to fetch
     * @returns {Promise<Object>} The response data
     */
    async getId(id, amount = 10) {
        return await this._get(`/quiz/id/${id}`, {
            amount: amount.toString(),
            refresh: 'true'
        });
    }
}
