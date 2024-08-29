import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:youtube_clone/utils/getter.dart';

class SocketProvider with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(BuildContext context) {
    _socket = IO.io(getBaseUrl(), {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.on('connect', (_) {
      _isConnected = true;
      notifyListeners();
    });

    _socket?.on('disconnect', (_) {
      _isConnected = false;
      notifyListeners();
    });

    // Listen for video events and update the VideoProvider
    _socket?.on('video.created', (_) => notifyListeners());
    _socket?.on('video.updated', (_) => notifyListeners());
    _socket?.on('video.deleted', (_) => notifyListeners());
    _socket?.on('comment.created', (_) => notifyListeners());
    _socket?.on('user.updated', (_) => notifyListeners());
    _socket?.on('user.created', (_) => notifyListeners());
    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
  }
}