import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:youtube_clone/services/video_service.dart';
import 'dart:convert';
import 'package:youtube_clone/utils/getter.dart';

class UserService {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/auth/local'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['jwt'];
    } else {
      return null;
    }
  }

  Future<Map?> me(String jwtToken) async {
    final response = await http.get(
      Uri.parse('${getBaseUrl()}/api/users/me?populate=role,profile_picture,'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": 'Bearer $jwtToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return null;
    }
  }

  Future<String?> signup(File profilePicturefile, String email, String username,
      String password) async {
    try {
      final profilePictureid =
          await VideoService().uploadFile(profilePicturefile, 'image');

      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/auth/local/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          "email": email,
          'profile_picture': profilePictureid
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['jwt'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }
}