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

// Root route for API server verification
app.get('/', (req, res) => {
  res.json({ success: true, message: 'SmartGPT Backend Server is active and running!', health: '/health' });
});

// Base route for API health check
app.get('/health', (req, res) => {
  res.json({ success: true, status: 'API is up and running' });
});

// Error handling middlewares
app.use(notFound);
app.use(errorHandler);

module.exports = app;
