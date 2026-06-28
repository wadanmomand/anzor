const User = require('../models/User');
const Prompt = require('../models/Prompt');

// @desc    Toggle follow/unfollow a user
// @route   POST /api/social/follow/:userId
// @access  Private
exports.toggleFollowUser = async (req, res, next) => {
  try {
    const targetUserId = req.params.userId;
    const currentUserId = req.user._id;

    // Check if target user exists
    const targetUser = await User.findById(targetUserId);
    if (!targetUser) {
      res.status(404);
      throw new Error('User to follow not found.');
    }

    // Check that user is not trying to follow themselves
    if (targetUserId === currentUserId.toString()) {
      res.status(400);
      throw new Error('You cannot follow yourself.');
    }

    // Verify current follow state
    const isFollowing = req.user.following.includes(targetUserId);

    if (isFollowing) {
      // Unfollow atomic update
      await User.findByIdAndUpdate(currentUserId, {
        $pull: { following: targetUserId },
      });
      await User.findByIdAndUpdate(targetUserId, {
        $pull: { followers: currentUserId },
      });
    } else {
      // Follow atomic update
      await User.findByIdAndUpdate(currentUserId, {
        $push: { following: targetUserId },
      });
      await User.findByIdAndUpdate(targetUserId, {
        $push: { followers: currentUserId },
      });
    }

    // Retrieve the updated target user to return the new followers count
    const updatedTargetUser = await User.findById(targetUserId);

    res.json({
      status: 'success',
      isFollowing: !isFollowing,
      followersCount: updatedTargetUser.followers.length,
      followingCount: updatedTargetUser.following.length,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Toggle like/unlike on a prompt
// @route   POST /api/social/like/:promptId
// @access  Private
exports.toggleLikePrompt = async (req, res, next) => {
  try {
    const promptId = req.params.promptId;
    const currentUserId = req.user._id;

    const prompt = await Prompt.findById(promptId);
    if (!prompt) {
      res.status(404);
      throw new Error('Prompt not found.');
    }

    const isLiked = prompt.likes.includes(currentUserId);

    if (isLiked) {
      // Pull user from likes array
      prompt.likes.pull(currentUserId);
    } else {
      // Push user to likes array
      prompt.likes.push(currentUserId);
    }

    await prompt.save();

    res.json({
      status: 'success',
      isLikedByMe: !isLiked,
      likesCount: prompt.likes.length,
    });
  } catch (error) {
    next(error);
  }
};
