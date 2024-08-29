import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_clone/providers/user_provider.dart';
import 'dart:io';
import 'package:youtube_clone/providers/video_provider.dart';
import 'package:youtube_clone/screens/home_screen.dart';
import 'package:youtube_clone/utils/getter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _thumbnailFile;
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(children: [
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              await userProvider.logout();
            },
            child: const Text('Logout'),
          )
        ]),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      '${getBaseUrl()}${userProvider.user?['profile_picture']['url']}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProvider.user?['username'],
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('@${userProvider.user?['username']}',
                            style: const TextStyle(color: Colors.grey)),
                        Text(
                            '${userProvider.user?['subscribers']?.length ?? 0} subscribers • ${userProvider.user?['videos']?.length ?? 0} videos',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userProvider.user?['bio'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text('Manage videos'),
                      onPressed: _showAddVideoModal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVideoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final videoProvider =
            Provider.of<VideoProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {
                          _thumbnailFile = image;
                        });
                      },
                      child: Text('Pick Thumbnail Image'),
                    ),
                    SizedBox(height: 8),
                    _thumbnailFile != null
                        ? Image.file(File(_thumbnailFile!.path), height: 100)
                        : Container(),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final XFile? video = await _picker.pickVideo(
                            source: ImageSource.gallery);
                        setState(() {
                          _videoFile = video;
                          if (video != null) {
                            _videoPlayerController =
                                VideoPlayerController.file(File(video.path))
                                  ..initialize().then((_) {
                                    setState(() {});
                                  });
                          }
                        });
                      },
                      child: Text('Pick Video File'),
                    ),
                    SizedBox(height: 8),
                    _videoFile != null
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController?.value.aspectRatio ??
                                    16 / 9,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : Container(),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_thumbnailFile != null && _videoFile != null) {
                          await videoProvider.uploadFile(
                              File(_thumbnailFile!.path),
                              File(_videoFile!.path),
                              _titleController.text,
                              _descriptionController.text,
                              userProvider.user?['documentId']);
                          Navigator.pop(context); // Close the modal
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Missing Files'),
                                content: const Text(
                                    'Please select both an image and a video.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text('Upload Video'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}