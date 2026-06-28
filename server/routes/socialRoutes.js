const express = require('express');
const {
  toggleFollowUser,
  toggleLikePrompt,
} = require('../controllers/socialController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Private/Protected routes for social actions
router.post('/follow/:userId', protect, toggleFollowUser);
router.post('/like/:promptId', protect, toggleLikePrompt);

module.exports = router;
