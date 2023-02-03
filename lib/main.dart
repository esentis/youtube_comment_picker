import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:youtube_comment_picker/screens/landing_screen.dart';

Future<void> main() async {
  setPathUrlStrategy();
  await dotenv.load(fileName: 'dotenv');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Comment Picker',
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      home: const LandingScreen(title: 'YouTube Comment Picker'),
    );
  }
}
