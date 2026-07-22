import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Retrieve the saved authorization token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Save the authorization token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear session credentials
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Check if user has an active, saved session
  Future<bool> hasSavedSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Register a new user
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      if (token != null) {
        await _saveToken(token);
      }

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  /// Authenticate user credentials
  Future<User> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      if (token != null) {
        await _saveToken(token);
      }

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  /// Retrieve active user details
  Future<User> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching profile.');
    }
  }

  /// Delete account and clear local session
  Future<void> deleteAccount() async {
    try {
      await _dioClient.dio.delete(ApiConstants.deleteAccount);
      await clearSession();
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting account.');
    }
  }
}
