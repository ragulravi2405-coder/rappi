import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  List<Chat> _chats = [];
  Chat? _selectedChat;
  List<Message> _messages = [];

  bool _isChatsLoading = false;
  bool _isMessagesLoading = false;
  bool _isAiGenerating = false;
  String? _errorMessage;
  String _streamingText = '';

  ChatProvider({ChatService? chatService}) : _chatService = chatService ?? ChatService();

  List<Chat> get chats => _chats;
  Chat? get selectedChat => _selectedChat;
  List<Message> get messages => _messages;

  bool get isChatsLoading => _isChatsLoading;
  bool get isMessagesLoading => _isMessagesLoading;
  bool get isAiGenerating => _isAiGenerating;
  String? get errorMessage => _errorMessage;
  String get streamingText => _streamingText;

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Load all chats for the user
  Future<void> loadChats() async {
    _isChatsLoading = true;
    _setError(null);
    notifyListeners();

    try {
      _chats = await _chatService.getChats();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isChatsLoading = false;
      notifyListeners();
    }
  }

  /// Select a chat room and pull its historical messages
  Future<void> selectChat(Chat chat) async {
    _selectedChat = chat;
    _messages = [];
    _setError(null);
    notifyListeners();

    await loadMessages(chat.id);
  }

  /// Clear active chat selection
  void clearSelection() {
    _selectedChat = null;
    _messages = [];
    notifyListeners();
  }

  /// Load message history for a chat
  Future<void> loadMessages(String chatId) async {
    _isMessagesLoading = true;
    _setError(null);
    notifyListeners();

    try {
      _messages = await _chatService.getChatMessages(chatId);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isMessagesLoading = false;
      notifyListeners();
    }
  }

  /// Create a new chat session
  Future<Chat?> createChat(String title) async {
    _isChatsLoading = true;
    _setError(null);
    notifyListeners();

    try {
      final newChat = await _chatService.createChat(title);
      _chats.insert(0, newChat);
      _selectedChat = newChat;
      _messages = [];
      _isChatsLoading = false;
      notifyListeners();
      return newChat;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _isChatsLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Rename a chat room
  Future<bool> renameChat(String chatId, String newTitle) async {
    _setError(null);
    try {
      final updatedChat = await _chatService.renameChat(chatId, newTitle);
      
      final index = _chats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        _chats[index] = updatedChat;
      }
      if (_selectedChat?.id == chatId) {
        _selectedChat = updatedChat;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Delete a chat and reset selection if it was active
  Future<bool> deleteChat(String chatId) async {
    _setError(null);
    try {
      await _chatService.deleteChat(chatId);
      _chats.removeWhere((c) => c.id == chatId);
      
      if (_selectedChat?.id == chatId) {
        _selectedChat = null;
        _messages = [];
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Delete a specific message from history
  Future<bool> deleteMessage(String messageId) async {
    _setError(null);
    try {
      await _chatService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Send message and listen to streaming output
  Future<void> sendMessage(String content) async {
    if (_selectedChat == null) return;
    final chatId = _selectedChat!.id;

    // Add user message locally for immediate responsiveness
    final tempUserMessage = Message(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(tempUserMessage);

    _isAiGenerating = true;
    _streamingText = '';
    _setError(null);
    notifyListeners();

    try {
      final stream = _chatService.sendMessageStream(chatId, content);
      await for (final chunk in stream) {
        _streamingText += chunk;
        notifyListeners();
      }

      // Re-fetch to align list with MongoDB IDs and exact timestamps
      await loadMessages(chatId);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      // Remove temp user message if error occurred before successful save
      _messages.removeWhere((msg) => msg.id == tempUserMessage.id);
    } finally {
      _isAiGenerating = false;
      _streamingText = '';
      notifyListeners();
    }
  }

  /// Regenerate the last assistant response
  Future<void> regenerateResponse() async {
    if (_selectedChat == null || _messages.isEmpty) return;

    // Find the last user message and clean up assistant responses below it
    int lastUserMsgIndex = _messages.lastIndexWhere((m) => m.isUser);
    if (lastUserMsgIndex == -1) return;

    final String lastUserContent = _messages[lastUserMsgIndex].content;

    // Remove everything from the end of the list down to the last user message
    // but keep the user message itself.
    while (_messages.length > lastUserMsgIndex) {
      final removed = _messages.removeLast();
      // Clean from DB if it has a real DB ID
      if (!removed.id.startsWith('temp_')) {
        try {
          await _chatService.deleteMessage(removed.id);
        } catch (_) {}
      }
    }

    // Now re-trigger message send
    await sendMessage(lastUserContent);
  }

  /// Continue message response from the assistant
  Future<void> continueResponse() async {
    if (_selectedChat == null) return;
    // Tell assistant to continue
    await sendMessage('Continue writing the response from where you left off.');
  }
}
