const Chat = require('../models/Chat');
const Message = require('../models/Message');
const groqService = require('../services/groqService');

const SYSTEM_PROMPT = {
  role: 'system',
  content: 'You are SmartGPT, a helpful, advanced, and friendly AI assistant. Give comprehensive, high-quality, and clean answers. Format your output nicely using markdown and highlight code blocks properly.',
};

/**
 * Helper to extract text from Groq SSE chunk
 */
const parseGroqSSEChunk = (chunk) => {
  let content = '';
  const lines = chunk.split('\n');
  for (const line of lines) {
    const cleanLine = line.trim();
    if (!cleanLine || !cleanLine.startsWith('data: ')) continue;
    
    const dataStr = cleanLine.slice(6).trim();
    if (dataStr === '[DONE]') continue;
    
    try {
      const parsed = JSON.parse(dataStr);
      const text = parsed.choices[0]?.delta?.content || '';
      content += text;
    } catch (e) {
      // Ignored: chunk might be fragmented JSON
    }
  }
  return content;
};

/**
 * @desc    Post a new message in a chat and get AI response (Supports Streaming & Non-Streaming)
 * @route   POST /api/messages
 * @access  Private
 */
const handleMessage = async (req, res) => {
  try {
    const { chatId, content, stream = true } = req.body;

    // Verify chat belongs to user
    const chat = await Chat.findOne({ _id: chatId, userId: req.user._id });
    if (!chat) {
      return res.status(404).json({ success: false, message: 'Chat not found or access denied' });
    }

    // 1. Save user's message
    const userMessage = await Message.create({
      chatId,
      role: 'user',
      content,
    });

    // Update chat timestamp
    chat.updatedAt = new Date();
    await chat.save();

    // 2. Fetch conversation history for memory
    const history = await Message.find({ chatId }).sort({ timestamp: 1 });
    const messages = [
      SYSTEM_PROMPT,
      ...history.map((msg) => ({
        role: msg.role,
        content: msg.content,
      })),
    ];

    if (!stream) {
      // Non-streaming mode
      const assistantResponse = await groqService.generateChatCompletion(messages);
      
      // Save assistant response
      const assistantMessage = await Message.create({
        chatId,
        role: 'assistant',
        content: assistantResponse.content,
      });

      return res.status(201).json({
        success: true,
        userMessage,
        assistantMessage,
      });
    } else {
      // Streaming mode
      const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
        },
        body: JSON.stringify({
          model: process.env.GROQ_MODEL || 'llama-3.1-8b-instant',
          messages: messages,
          temperature: 0.7,
          max_tokens: 2048,
          stream: true,
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        return res.status(500).json({ success: false, message: `Groq Streaming Error: ${errText}` });
      }

      // Set streaming headers
      res.setHeader('Content-Type', 'text/event-stream');
      res.setHeader('Cache-Control', 'no-cache');
      res.setHeader('Connection', 'keep-alive');

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let fullContent = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        fullContent += parseGroqSSEChunk(chunk);
        res.write(chunk);
      }

      res.end();

      // Save assistant message to DB after stream ends
      if (fullContent.trim()) {
        await Message.create({
          chatId,
          role: 'assistant',
          content: fullContent,
        });
      }
    }
  } catch (error) {
    console.error('Message Handler Error:', error.message);
    if (!res.headersSent) {
      res.status(500).json({ success: false, message: error.message });
    } else {
      res.write(`data: [ERROR] ${error.message}\n\n`);
      res.end();
    }
  }
};

/**
 * @desc    Get raw direct completion (not saved to database)
 * @route   POST /api/ai/chat
 * @access  Private
 */
const directChat = async (req, res) => {
  try {
    const { messages, stream = false } = req.body;

    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ success: false, message: 'messages array is required' });
    }

    const payload = [SYSTEM_PROMPT, ...messages];

    if (!stream) {
      const completion = await groqService.generateChatCompletion(payload);
      return res.json({ success: true, choice: completion });
    } else {
      await groqService.streamChatCompletion(payload, res);
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  handleMessage,
  directChat,
};
