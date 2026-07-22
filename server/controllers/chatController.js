const Chat = require('../models/Chat');
const Message = require('../models/Message');

/**
 * @desc    Get all chats for the logged in user
 * @route   GET /api/chats
 * @access  Private
 */
const getUserChats = async (req, res) => {
  try {
    const chats = await Chat.find({ userId: req.user._id }).sort({ updatedAt: -1 });
    res.json({ success: true, chats });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * @desc    Create a new chat
 * @route   POST /api/chats
 * @access  Private
 */
const createChat = async (req, res) => {
  try {
    const { title } = req.body;
    
    const chat = await Chat.create({
      userId: req.user._id,
      title: title || 'New Chat',
    });

    res.status(201).json({ success: true, chat });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * @desc    Rename a chat
 * @route   PUT /api/chats/:id
 * @access  Private
 */
const renameChat = async (req, res) => {
  try {
    const { title } = req.body;
    
    if (!title || title.trim() === '') {
      return res.status(400).json({ success: false, message: 'Title is required' });
    }

    const chat = await Chat.findOne({ _id: req.params.id, userId: req.user._id });
    if (!chat) {
      return res.status(404).json({ success: false, message: 'Chat not found' });
    }

    chat.title = title;
    await chat.save();

    res.json({ success: true, chat });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * @desc    Delete a chat and its messages
 * @route   DELETE /api/chats/:id
 * @access  Private
 */
const deleteChat = async (req, res) => {
  try {
    const chat = await Chat.findOne({ _id: req.params.id, userId: req.user._id });
    if (!chat) {
      return res.status(404).json({ success: false, message: 'Chat not found' });
    }

    // Delete all messages in the chat
    await Message.deleteMany({ chatId: chat._id });

    // Delete the chat itself
    await Chat.deleteOne({ _id: chat._id });

    res.json({ success: true, message: 'Chat and messages deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getUserChats,
  createChat,
  renameChat,
  deleteChat,
};
