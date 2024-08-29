import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_clone/providers/user_provider.dart';
import 'package:youtube_clone/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  XFile? _profilePicture;
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final ImagePicker _picker = ImagePicker();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!_isLogin)
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (!_isLogin)
                _profilePicture == null
                    ? TextButton(
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {
                            _profilePicture = pickedFile;
                          });
                        },
                        child: const Text('Select Profile Picture'),
                      )
                    : Column(
                        children: [
                          Image.file(
                            File(_profilePicture!.path),
                            height: 100,
                            width: 100,
                          ),
                          TextButton(
                            onPressed: () async {
                              final pickedFile = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                _profilePicture = pickedFile;
                              });
                            },
                            child: const Text('Change Profile Picture'),
                          ),
                        ],
                      ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_isLogin) {
                    await userProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                  } else {
                    await userProvider.signup(
                      File(_profilePicture!.path),
                      _emailController.text,
                      _usernameController.text,
                      _passwordController.text,
                    );
                  }

                  if (userProvider.token != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Login'),
              ),
              const SizedBox(height: 20),
              Text(userProvider.message ?? "")
            ],
          ),
        ),
      ),
    );
  }
}