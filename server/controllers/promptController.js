const { GoogleGenerativeAI } = require('@google/generative-ai');
const Prompt = require('../models/Prompt');

// Initialize Gemini API Client
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'dummy_key');

// @desc    Get global prompt feed (approved prompts)
// @route   GET /api/prompts
// @access  Public
exports.getGlobalFeed = async (req, res, next) => {
  try {
    const { category, style, sort } = req.query;
    
    // Default filter for approved prompts
    const filter = { status: 'approved' };

    // Apply category filter if not 'All'
    if (category && category.toLowerCase() !== 'all') {
      filter.category = new RegExp(`^${category}$`, 'i');
    }

    // Apply style filter if provided
    if (style && style.toLowerCase() !== 'all') {
      filter.style = new RegExp(`^${style}$`, 'i');
    }

    // Build query
    let query = Prompt.find(filter);

    // Apply sorting
    if (sort === 'trending') {
      // Sort by likes array length in descending order
      query = query.sort({ likesCount: -1, createdAt: -1 });
    } else {
      // Default: sort by latest
      query = query.sort({ createdAt: -1 });
    }

    const prompts = await query;
    res.json({
      status: 'success',
      count: prompts.length,
      prompts: prompts.map(p => p.toJSON()),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get prompts from users the current user follows
// @route   GET /api/prompts/following
// @access  Private
exports.getFollowingFeed = async (req, res, next) => {
  try {
    const followingIds = req.user.following || [];

    if (followingIds.length === 0) {
      return res.json({
        status: 'success',
        count: 0,
        prompts: [],
      });
    }

    // Find approved prompts by users in the following list
    const prompts = await Prompt.find({
      ownerId: { $in: followingIds },
      status: 'approved',
    }).sort({ createdAt: -1 });

    res.json({
      status: 'success',
      count: prompts.length,
      prompts: prompts.map(p => p.toJSON()),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Secure server-side prompt generation/expansion with Gemini
// @route   POST /api/prompts/generate
// @access  Private
exports.generatePromptWithGemini = async (req, res, next) => {
  try {
    const { rawIdea, category, style } = req.body;

    if (!rawIdea || rawIdea.trim() === '') {
      res.status(400);
      throw new Error('Please provide a raw idea to expand.');
    }

    // Validate that the Gemini key is present
    if (!process.env.GEMINI_API_KEY || process.env.GEMINI_API_KEY === 'YOUR_GEMINI_API_KEY') {
      res.status(500);
      throw new Error('Gemini API key is not configured on the server. Please add it to the .env file.');
    }

    // Initialize Generative Model
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    // Build the instruction
    const systemPrompt = `You are a professional Prompt Engineer and Creative Director.
Expand the following basic idea into a highly descriptive, visually rich, and detailed prompt.
The output prompt will be used in AI image generators like Midjourney or Stable Diffusion.
Add specific terms describing styles, lighting directions, texture descriptors, camera lens/angles, and quality modifiers.
If a category or style is requested, tailor the prompts keywords towards that theme.

Desired Category: ${category || 'General'}
Desired Style: ${style || 'Digital Art'}
Basic Idea: "${rawIdea}"

Provide ONLY the final expanded prompt text. Do NOT wrap it in quotes, markdown code blocks, or include introductory/explanatory sentences.`;

    const result = await model.generateContent(systemPrompt);
    const response = await result.response;
    const expandedPromptText = response.text().trim();

    res.json({
      status: 'success',
      rawIdea,
      expandedPrompt: expandedPromptText,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Submit a new prompt to moderation
// @route   POST /api/prompts
// @access  Private
exports.submitPrompt = async (req, res, next) => {
  try {
    const { title, prompt, description, category, style, image } = req.body;

    if (!title || !prompt) {
      res.status(400);
      throw new Error('Please enter title and prompt fields.');
    }

    const newPrompt = await Prompt.create({
      title,
      prompt,
      description,
      category: category || 'All',
      style: style || 'Digital Art',
      image: image || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&q=80',
      ownerId: req.user._id,
      ownerName: req.user.username,
      ownerAvatar: req.user.avatar,
      status: 'pending',
    });

    res.status(201).json(newPrompt.toJSON()); // Return the parsed JSON directly for matching Dart JSON parser
  } catch (error) {
    next(error);
  }
};

