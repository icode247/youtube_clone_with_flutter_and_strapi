import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:youtube_clone/utils/getter.dart';

class VideoService {
  static const String populateQuery =
      'populate[comments][populate][user][populate][profile_picture]=profile_picture&populate[thumbnail]=*&populate[video_file]=*&populate[likes]=*&populate[views]=*&populate[comments][populate]=*&populate[uploader][populate]=profile_picture&populate[uploader][populate]=subscribers';
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> fetchVideos() async {
    final response =
        await http.get(Uri.parse('${getBaseUrl()}/api/videos?$populateQuery'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Extract the list of videos from the 'data' field
      return responseData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<Map<String, dynamic>> fetchVideo(String documentId) async {
    final response = await http
        .get(Uri.parse('$getBaseUrl()/api/videos/$documentId/$populateQuery'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Extract the list of videos from the 'data' field
      return responseData['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> uploadVideoContent(File videoFile, File thumbnailFile,
      String title, String description, String userId) async {
    try {
      final baseUrl = getBaseUrl();

      final videoId = await uploadFile(videoFile, 'video');

      final thumbnailId = await uploadFile(thumbnailFile, 'image');

      await createVideoEntry(
          baseUrl, videoId, thumbnailId, title, description, userId);
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<String> uploadFile(File file, String fileType) async {
    final uri = Uri.parse('${getBaseUrl()}/api/upload');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('files', file.path));

    var response = await request.send();
    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse[0]['id'].toString();
    } else {
      throw Exception('Failed to upload $fileType');
    }
  }

  Future<void> createVideoEntry(String baseUrl, String videoId,
      String thumbnailId, String title, String description, userId) async {
    final uri = Uri.parse('$baseUrl/api/videos');
    final token = await _getAuthToken();
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "data": {
          "title": title,
          "description": description,
          "video_file": videoId,
          "thumbnail": thumbnailId,
          "uploader": userId
        }
      }),
    );

    if (response.statusCode == 201) {
      print('Video entry created successfully');
    } else {
      print('Failed to create video entry: ${response.body}');
      throw Exception('Failed to create video entry');
    }
  }

  Future<void> likeVideo(String videoId) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('${getBaseUrl()}/api/videos/$videoId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like video');
    }
  }

  Future<void> increaseViews(String videoId) async {
    final token = await _getAuthToken();

    final response = await http.put(
      Uri.parse('${getBaseUrl()}/api/videos/$videoId/increment-view'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to increase views: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<void> commentOnVideo(
      String videoId, String comment, String userId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/comments?populate=*'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "data": {'text': comment, "user": userId, "video": videoId}
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post comment: ${response.body}');
    }
  }

  Future subscribeToChannel(int userId) async {
    final uri = Uri.parse('${getBaseUrl()}/api/videos/$userId/subscribe');
    final token = await _getAuthToken();
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('Subscription created successfully');
    } else {
      print('Failed to create subscription: ${response.body}');
      throw Exception('Failed to create subscription');
    }
  }
}
