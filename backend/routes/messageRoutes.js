const express = require('express');
const { getChatMessages, deleteMessage } = require('../controllers/messageController');
const { handleMessage } = require('../controllers/aiController');
const { protect } = require('../middleware/authMiddleware');
const { messageValidator } = require('../utils/validators');

const router = express.Router();

router.use(protect); // All message routes require JWT authentication

router.get('/:chatId', getChatMessages);
router.post('/', messageValidator, handleMessage);
router.delete('/:id', deleteMessage);

module.exports = router;
