const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const { username, email, password } = req.body;

    // Check for required fields
    if (!username || !email || !password) {
      res.status(400);
      throw new Error('Please enter all fields: username, email, and password.');
    }

    // Check if user already exists
    const userExists = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { username }],
    });

    if (userExists) {
      res.status(400);
      if (userExists.username === username) {
        throw new Error('Username is already taken.');
      } else {
        throw new Error('An account with this email already exists.');
      }
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Assign a default bottts avatar via Dicebear using the username
    const avatar = `https://api.dicebear.com/7.x/bottts/svg?seed=${encodeURIComponent(username)}`;

    // Create user
    const user = await User.create({
      username,
      email: email.toLowerCase(),
      passwordHash,
      avatar,
      coverBanner: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop', // default premium gradient-ish banner
      bio: `Hello! I'm ${username}, a prompt designer on Anzor AI.`,
    });

    if (user) {
      res.status(201).json({
        status: 'success',
        message: 'Registration successful!',
        user: user.toJSON(),
      });
    } else {
      res.status(400);
      throw new Error('Invalid user data received.');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Authenticate a user & get token
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Check for required fields
    if (!email || !password) {
      res.status(400);
      throw new Error('Please provide email and password.');
    }

    // Find user by email (case-insensitive)
    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      res.status(401);
      throw new Error('Invalid email or password.');
    }

    // Check password match
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      res.status(401);
      throw new Error('Invalid email or password.');
    }

    // Sign JWT token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '30d' }
    );

    res.json({
      status: 'success',
      token,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user profile (protected check)
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    // req.user is set by authMiddleware
    res.json({
      status: 'success',
      user: req.user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};
