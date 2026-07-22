const express = require('express');
const {
  getUserChats,
  createChat,
  renameChat,
  deleteChat,
} = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');
const { chatValidator } = require('../utils/validators');

const router = express.Router();

router.use(protect); // All chat routes require JWT authentication

router.get('/', getUserChats);
router.post('/', chatValidator, createChat);
router.put('/:id', chatValidator, renameChat);
router.delete('/:id', deleteChat);

module.exports = router;
