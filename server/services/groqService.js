const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
const DEFAULT_MODEL = 'llama-3.1-8b-instant';

/**
 * Get headers for Groq API request
 */
const getHeaders = () => {
  if (!process.env.GROQ_API_KEY) {
    throw new Error('GROQ_API_KEY environment variable is not defined.');
  }
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
  };
};

/**
 * Generate chat completion (non-streaming)
 * @param {Array} messages - Array of message objects {role, content}
 * @returns {Promise<Object>} The API response completion message
 */
const generateChatCompletion = async (messages) => {
  try {
    const response = await fetch(GROQ_API_URL, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        model: process.env.GROQ_MODEL || DEFAULT_MODEL,
        messages: messages,
        temperature: 0.7,
        max_tokens: 2048,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Groq API returned status ${response.status}: ${errText}`);
    }

    const data = await response.json();
    return data.choices[0].message;
  } catch (error) {
    console.error('Groq API Error:', error.message);
    throw error;
  }
};

/**
 * Stream chat completion directly to Express response
 * @param {Array} messages - Array of message objects {role, content}
 * @param {Response} res - Express response object
 */
const streamChatCompletion = async (messages, res) => {
  try {
    const response = await fetch(GROQ_API_URL, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        model: process.env.GROQ_MODEL || DEFAULT_MODEL,
        messages: messages,
        temperature: 0.7,
        max_tokens: 2048,
        stream: true,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Groq Streaming API returned status ${response.status}: ${errText}`);
    }

    // Set SSE headers for client
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      res.write(chunk);
    }

    res.end();
  } catch (error) {
    console.error('Groq Streaming Error:', error.message);
    // If headers are already sent, end response
    if (res.headersSent) {
      res.write(`data: [ERROR] ${error.message}\n\n`);
      res.end();
    } else {
      res.status(500).json({ success: false, message: error.message });
    }
  }
};

module.exports = {
  generateChatCompletion,
  streamChatCompletion,
};
