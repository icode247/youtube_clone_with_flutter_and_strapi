import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_clone/providers/socket_provider.dart';
import 'package:youtube_clone/providers/user_provider.dart';
import 'package:youtube_clone/providers/video_provider.dart';
import 'package:youtube_clone/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => VideoProvider(context),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Connect to the socket when the app starts
    Provider.of<SocketProvider>(context, listen: false).connect(context);

    return MaterialApp(
      title: 'YouTube Clone',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white70),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[850],
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          brightness: Brightness.dark,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        cardColor: Colors.grey[900],
        dividerColor: Colors.grey[700],
      ),
      home: const HomeScreen(),
    );
  }
}
