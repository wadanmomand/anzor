const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;

  // Check if Bearer token exists in the Authorization header
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Get token from header: "Bearer <token>"
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

      // Get user from database (excluding passwordHash)
      req.user = await User.findById(decoded.id);

      if (!req.user) {
        res.status(401);
        throw new Error('Unauthorized: User not found on database.');
      }

      next();
    } catch (error) {
      console.error(`[Auth Error] ${error.message}`);
      res.status(401);
      next(new Error('Unauthorized: Invalid or expired token.'));
    }
  } else {
    res.status(401);
    next(new Error('Unauthorized: No authorization token provided.'));
  }
};

module.exports = { protect };
