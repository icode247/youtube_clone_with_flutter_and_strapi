import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_clone/providers/user_provider.dart';
import 'package:youtube_clone/providers/video_provider.dart';
import 'package:youtube_clone/utils/getter.dart';
import 'package:youtube_clone/screens/video_player_screen.dart';
import 'package:youtube_clone/screens/auth_screen.dart';
import 'package:youtube_clone/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).fetchVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/YouTube_logo.png',
              width: 90,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: VideoSearchDelegate(),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: userProvider.token != null
                  // ignore: dead_code
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${getBaseUrl()}${userProvider.user?['profile_picture']['url']}',
                      ),
                      radius: 20,
                    )
                  // ignore: dead_code
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      },
                      child: const Text('Sign in'),
                    ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                if (videoProvider.videos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: videoProvider.videos.length,
                  itemBuilder: (context, index) {
                    final video = videoProvider.videos[index];
                    return _buildVideoTitle(video);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTitle(Map<String, dynamic> video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            await Provider.of<VideoProvider>(context, listen: false)
                .increaseViews(video['documentId']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(videoId: video['documentId']),
              ),
            );
          },
          child: Stack(
            children: [
              Image.network(
                '${getBaseUrl()}${video['thumbnail']['url']}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              '${getBaseUrl()}${video['uploader']['profile_picture']['url']}',
            ),
            radius: 20,
          ),
          title: GestureDetector(
            onTap: () async {
              await Provider.of<VideoProvider>(context, listen: false)
                  .increaseViews(video['documentId']);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VideoPlayerScreen(videoId: video['documentId']),
                ),
              );
            },
            child: Text(
              video['title'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(
            '${video['uploader']['username']} • ${video['views']?.length.toString()} views • ${_formatDaysAgo(video['publishedAt'])}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
          onTap: () async {
            await Provider.of<VideoProvider>(context, listen: false)
                .increaseViews(video['documentId']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(videoId: video['documentId']),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDaysAgo(String publishedAt) {
    final publishedDate = DateTime.parse(publishedAt);
    final now = DateTime.now();
    final difference = now.difference(publishedDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '$difference days ago';
    }
  }
}

class VideoSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final results = videoProvider.videos
        .where((video) =>
            video['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final video = results[index];
        return ListTile(
          title: Text(video['title']),
          onTap: () async {
            await Provider.of<VideoProvider>(context, listen: false)
                .increaseViews(video['documentId']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(videoId: video['documentId']),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final suggestions = videoProvider.videos
        .where((video) =>
            video['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion['title']),
          onTap: () {
            query = suggestion['title'];
            showResults(context);
          },
        );
      },
    );
  }
}
