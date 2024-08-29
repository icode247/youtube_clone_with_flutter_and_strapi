import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_clone/providers/socket_provider.dart';
import 'package:youtube_clone/services/video_service.dart';

class VideoProvider with ChangeNotifier {
  List _videos = [];
  Map _video = {};

  List get videos => _videos;

  VideoProvider(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.addListener(_handleSocketEvents);
  }

  void _handleSocketEvents() {
    fetchVideos();
  }

  Future fetchVideos() async {
    try {
      _videos = await VideoService().fetchVideos();
      notifyListeners();
    } catch (error) {
      print("Error fetching videos: $error");
    }
  }

  Future fetchVideo(String documentId) async {
    try {
      _video = await VideoService().fetchVideo(documentId);
      notifyListeners();
    } catch (error) {
      print("Error fetching videos: $error");
    }
  }

  Future likeVideo(String videoId) async {
    try {
      await VideoService().likeVideo(videoId);
      notifyListeners();
    } catch (error) {
      print("Error liking video: $error");
    }
  }

  Future increaseViews(String videoId) async {
    try {
      await VideoService().increaseViews(videoId);
      notifyListeners();
    } catch (error) {
      print("Error increasing views: $error");
    }
  }

  Future commentOnVideo(String videoId, String comment, String userId) async {
    try {
      await VideoService().commentOnVideo(videoId, comment, userId);
      notifyListeners();
    } catch (error) {
      print("Error commenting on video: $error");
    }
  }

  Future uploadFile(
      File imageFile, File videoFile, String title, String description, String userId) async {
    try {
      await VideoService().uploadVideoContent(
        videoFile,
        imageFile,
        title,
        description,
        userId
      );
      notifyListeners();
    } catch (error) {
      print("Error uploading file: $error");
    }
  }

  Future subscribeToChannel(int documentId) async {
    try {
      await VideoService().subscribeToChannel(documentId);
      notifyListeners();
    } catch (error) {
      print("Error subscribing to channel: $error");
    }
  }
}