const express = require('express');
const {
  getGlobalFeed,
  getFollowingFeed,
  generatePromptWithGemini,
  submitPrompt,
} = require('../controllers/promptController');
const { toggleLikePrompt } = require('../controllers/socialController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Public route to view global feed
router.get('/', getGlobalFeed);

// Private route to view feed from followed users
router.get('/following', protect, getFollowingFeed);

// Private route to securely generate/expand prompts via Gemini
router.post('/generate', protect, generatePromptWithGemini);

// Private route to submit a new prompt for approval
router.post('/', protect, submitPrompt);

// Private route to toggle like on a prompt
router.post('/like/:promptId', protect, toggleLikePrompt);

module.exports = router;
