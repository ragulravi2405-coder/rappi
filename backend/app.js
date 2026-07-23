const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');
const { apiLimiter } = require('./middleware/rateLimiter');

// Route files
const authRoutes = require('./routes/authRoutes');
const chatRoutes = require('./routes/chatRoutes');
const messageRoutes = require('./routes/messageRoutes');
const aiRoutes = require('./routes/aiRoutes');

const app = express();

// Security Headers
app.use(helmet());

// CORS configuration (allow requests from Flutter frontend client)
app.use(
  cors({
    origin: '*', // For development, allow all. Update with frontend domain in production
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Logging middleware
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Apply rate limiter to all API routes
app.use('/api', apiLimiter);

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/chats', chatRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/ai', aiRoutes);

// Root route for API server verification & browser dashboard
app.get('/', (req, res) => {
  if (req.accepts('html')) {
    res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SmartGPT Server Status</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
    body { background: #0b0f19; color: #f8fafc; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
    .card { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(16px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 20px; padding: 40px; max-width: 560px; width: 100%; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); text-align: center; }
    .badge { display: inline-flex; align-items: center; gap: 8px; background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.3); padding: 6px 16px; border-radius: 9999px; font-size: 0.875rem; font-weight: 600; margin-bottom: 20px; }
    .pulse { width: 8px; height: 8px; background: #22c55e; border-radius: 50%; box-shadow: 0 0 10px #22c55e; animation: pulse 2s infinite; }
    @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(1.2); } }
    h1 { font-size: 2.25rem; font-weight: 700; margin-bottom: 10px; background: linear-gradient(135deg, #a855f7, #6366f1, #3b82f6); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
    p { color: #94a3b8; line-height: 1.6; margin-bottom: 30px; font-size: 0.95rem; }
    .endpoints { background: rgba(15, 23, 42, 0.6); border-radius: 12px; padding: 20px; text-align: left; border: 1px solid rgba(255, 255, 255, 0.05); }
    .endpoints h3 { font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; color: #64748b; margin-bottom: 12px; }
    .item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255, 255, 255, 0.05); font-size: 0.875rem; }
    .item:last-child { border-bottom: none; }
    .method { font-weight: 700; color: #6366f1; }
    .path { font-family: monospace; color: #e2e8f0; }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge"><span class="pulse"></span> System Operational</div>
    <h1>SmartGPT Backend</h1>
    <p>The Express REST API server is online and running successfully on Render. Connect your SmartGPT Flutter app to start chatting!</p>
    <div class="endpoints">
      <h3>Active API Endpoints</h3>
      <div class="item"><span class="method">GET</span><span class="path"><a href="/health" style="color:#6366f1;text-decoration:none;">/health</a></span></div>
      <div class="item"><span class="method">POST</span><span class="path">/api/auth/login</span></div>
      <div class="item"><span class="method">POST</span><span class="path">/api/auth/register</span></div>
      <div class="item"><span class="method">POST</span><span class="path">/api/ai/chat</span></div>
    </div>
  </div>
</body>
</html>`);
  } else {
    res.json({ success: true, message: 'SmartGPT Backend Server is active and running!', health: '/health' });
  }
});

// Base route for API health check
app.get('/health', (req, res) => {
  res.json({ success: true, status: 'API is up and running' });
});

// Error handling middlewares
app.use(notFound);
app.use(errorHandler);

module.exports = app;
