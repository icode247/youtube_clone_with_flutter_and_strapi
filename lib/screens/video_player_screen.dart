import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_clone/providers/user_provider.dart';
import 'package:youtube_clone/providers/video_provider.dart';
import 'package:youtube_clone/utils/getter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoId != oldWidget.videoId) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final video = videoProvider.videos
        .firstWhere((v) => v['documentId'] == widget.videoId, orElse: () => {});
    print('${getBaseUrl()}${video['video_file']['url']}');
    if (video.isNotEmpty) {
      _controller = VideoPlayerController.network(
          '${getBaseUrl()}${video['video_file']['url']}')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(BuildContext context, String videoId) {
    if (_commentController.text.isNotEmpty) {
      final videoProvider = Provider.of<VideoProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      videoProvider.commentOnVideo(
          videoId, _commentController.text, userProvider.user?['documentId']);
      _commentController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        final video = videoProvider.videos.firstWhere(
            (v) => v['documentId'] == widget.videoId,
            orElse: () => {});
        if (video.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(child: Text('Video not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_controller.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.fullscreen),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullscreenVideoPlayer(
                                              controller: _controller),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video['title'] ?? 'No Title',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video['description'] ?? 'No Description',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  '${getBaseUrl()}${video['uploader']['profile_picture']['url']}'),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (video['uploader']['username']).toString(),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              (video['uploader']['subscribers']?.length ?? 0)
                                  .toString(),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await videoProvider
                                        .likeVideo(video['documentId']);
                                  },
                                  child: const Icon(Icons.thumb_up),
                                ),
                                Text(video['likes'].length.toString()),
                              ],
                            ),
                            const SizedBox(width: 15),
                            // Check if the user is logged in
                            if (userProvider.user != null)
                              ElevatedButton(
                                onPressed: () async {
                                        await videoProvider.subscribeToChannel(
                                            video['uploader']['id']);
                                      },
                                child: Text(
                                  video['uploader']['subscribers'] != null &&
                                          video['uploader']['subscribers']!.any(
                                              (subscriber) =>
                                                  subscriber['id'] ==
                                                  userProvider.user!['id'])
                                      ? "Unsubscribe"
                                      : "Subscribe",
                                ),
                              ),
                          ]),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Comments"),
                        const SizedBox(width: 8),
                        Text(video['comments'].length.toString()),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.black12,
                      child: Column(
                        children: video['comments'].map<Widget>((comment) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  '${getBaseUrl()}${comment['user']['profile_picture']['url']}'),
                            ),
                            title: Text(comment['user']['username']),
                            subtitle: Text(comment['text']),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
              if (userProvider.token != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _submitComment(context, video['documentId']),
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FullscreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const FullscreenVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}