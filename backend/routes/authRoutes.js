const express = require('express');
const {
  registerUser,
  loginUser,
  getUserProfile,
  deleteUserAccount,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/rateLimiter');
const { registerValidator, loginValidator } = require('../utils/validators');

const router = express.Router();

// Register and Login with validation and rate limiting
router.post('/register', authLimiter, registerValidator, registerUser);
router.post('/login', authLimiter, loginValidator, loginUser);

// Protected routes
router.get('/profile', protect, getUserProfile);
router.delete('/account', protect, deleteUserAccount);

module.exports = router;
