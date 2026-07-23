const Message = require('../models/Message');
const Chat = require('../models/Chat');

/**
 * @desc    Get all messages for a specific chat
 * @route   GET /api/messages/:chatId
 * @access  Private
 */
const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;

    // Verify chat belongs to user
    const chat = await Chat.findOne({ _id: chatId, userId: req.user._id });
    if (!chat) {
      return res.status(404).json({ success: false, message: 'Chat not found or access denied' });
    }

    const messages = await Message.find({ chatId }).sort({ timestamp: 1 });
    res.json({ success: true, messages });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * @desc    Delete a message from a chat
 * @route   DELETE /api/messages/:id
 * @access  Private
 */
const deleteMessage = async (req, res) => {
  try {
    const { id } = req.params;

    const message = await Message.findById(id);
    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    // Verify chat belongs to user
    const chat = await Chat.findOne({ _id: message.chatId, userId: req.user._id });
    if (!chat) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this message' });
    }

    await Message.findByIdAndDelete(id);
    res.json({ success: true, message: 'Message deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getChatMessages,
  deleteMessage,
};
