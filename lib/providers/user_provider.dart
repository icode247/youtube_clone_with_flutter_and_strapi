import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:youtube_clone/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _message;
  Map<String, dynamic>? _user;

  String? get token => _token;
  String? get message => _message;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      _token = await UserService().login(email, password);
      if (_token != null) {
        _user = (await UserService().me(_token!)) as Map<String, dynamic>?;
        await _storage.write(key: 'auth_token', value: _token);
        _message = null;
        notifyListeners();
      } else {
        _message = 'Invalid email or password';
        notifyListeners();
      }
    } catch (e) {
      _message = 'Failed to login. Please try again later.';
      notifyListeners();
    }
  }

  Future<void> signup(File profilePicturefile, String email, String username,
      String password) async {
    try {
      _token = await UserService()
          .signup(profilePicturefile, email, username, password);
      if (_token != null) {
        _user = (await UserService().me(_token!)) as Map<String, dynamic>?;
        await _storage.write(key: 'auth_token', value: _token);
        _message = null;
        notifyListeners();
      } else {
        _message = 'Signup failed. Please check your details and try again.';
        notifyListeners();
      }
    } catch (e) {
      print(e);
      _message = 'Failed to sign up. Please try again later.';
      notifyListeners();
    }
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = {};
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }
}