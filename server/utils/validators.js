const { body, validationResult } = require('express-validator');

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array().map((err) => ({
        field: err.path || err.param,
        message: err.msg,
      })),
    });
  }
  next();
};

const registerValidator = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Name is required')
    .isLength({ max: 50 })
    .withMessage('Name cannot exceed 50 characters'),
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please enter a valid email address')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  validateRequest,
];

const loginValidator = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please enter a valid email address')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  validateRequest,
];

const chatValidator = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Chat title is required')
    .isLength({ max: 100 })
    .withMessage('Title cannot exceed 100 characters'),
  validateRequest,
];

const messageValidator = [
  body('chatId')
    .notEmpty()
    .withMessage('Chat ID is required')
    .isMongoId()
    .withMessage('Invalid Chat ID format'),
  body('content')
    .trim()
    .notEmpty()
    .withMessage('Content cannot be empty'),
  validateRequest,
];

module.exports = {
  registerValidator,
  loginValidator,
  chatValidator,
  messageValidator,
};
