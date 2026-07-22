// Simple verification script to check backend files for syntax/import errors
try {
  console.log('Verifying Mongoose Models...');
  require('./models/User');
  require('./models/Chat');
  require('./models/Message');
  console.log('✓ Models loaded successfully.');

  console.log('Verifying Config and Services...');
  require('./config/db');
  require('./services/groqService');
  console.log('✓ Services loaded successfully.');

  console.log('Verifying Middlewares and Utils...');
  require('./middleware/authMiddleware');
  require('./middleware/rateLimiter');
  require('./middleware/errorMiddleware');
  require('./utils/validators');
  console.log('✓ Middlewares loaded successfully.');

  console.log('Verifying App routes and Assembly...');
  require('./app');
  console.log('✓ Express App loaded and routing resolved successfully.');
  console.log('\nBackend code has NO syntax or import structure errors!');
} catch (error) {
  console.error('\nVerification FAILED:', error.stack);
  process.exit(1);
}
