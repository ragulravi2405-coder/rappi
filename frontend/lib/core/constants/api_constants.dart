import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      return 'http://localhost:5000';
    }
    return url;
  }

  // Auth routes
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';
  static const String deleteAccount = '/api/auth/account';

  // Chat routes
  static const String chats = '/api/chats';
  
  // Message routes
  static const String messages = '/api/messages';
  
  // Direct AI completion
  static const String aiChat = '/api/ai/chat';
}
