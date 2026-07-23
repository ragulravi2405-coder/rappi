import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatService {
  final DioClient _dioClient;

  ChatService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch all chats of the user
  Future<List<Chat>> getChats() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.chats);
      final List data = response.data['chats'] ?? [];
      return data.map((json) => Chat.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching chats.');
    }
  }

  /// Create a new chat conversation
  Future<Chat> createChat(String title) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.chats,
        data: {'title': title},
      );
      return Chat.fromJson(response.data['chat']);
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while creating chat.');
    }
  }

  /// Rename an existing chat title
  Future<Chat> renameChat(String chatId, String newTitle) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.chats}/$chatId',
        data: {'title': newTitle},
      );
      return Chat.fromJson(response.data['chat']);
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while renaming chat.');
    }
  }

  /// Delete a chat and its messages
  Future<void> deleteChat(String chatId) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.chats}/$chatId');
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting chat.');
    }
  }

  /// Fetch message history for a specific chat room
  Future<List<Message>> getChatMessages(String chatId) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.messages}/$chatId');
      final List data = response.data['messages'] ?? [];
      return data.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching messages.');
    }
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.messages}/$messageId');
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting message.');
    }
  }

  /// Send message and listen to the streaming response from backend
  Stream<String> sendMessageStream(String chatId, String content) async* {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.messages,
        data: {
          'chatId': chatId,
          'content': content,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final ResponseBody responseBody = response.data;
      final stream = responseBody.stream;

      String carryString = '';
      await for (final List<int> bytes in stream) {
        final chunk = utf8.decode(bytes);
        final lines = (carryString + chunk).split('\n');
        carryString = lines.removeLast(); // Save potential incomplete last line

        for (final line in lines) {
          final cleanLine = line.trim();
          if (cleanLine.isEmpty) continue;
          if (!cleanLine.startsWith('data: ')) continue;

          final dataStr = cleanLine.substring(6).trim();
          if (dataStr == '[DONE]') continue;

          try {
            final Map<String, dynamic> json = jsonDecode(dataStr);
            final String text = json['choices']?[0]?['delta']?['content'] ?? '';
            if (text.isNotEmpty) {
              yield text;
            }
          } catch (e) {
            // Fragmented JSON line or incorrect format (silently skip)
          }
        }
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('Streaming generation failed.');
    }
  }
}
