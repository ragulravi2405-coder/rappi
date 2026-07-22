const express = require('express');
const { directChat } = require('../controllers/aiController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect); // Direct AI completion requires authentication

router.post('/chat', directChat);

module.exports = router;
