import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:youtube_comment_picker/constants.dart';
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kColorBackground,
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: kColorText,
          displayColor: kColorText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kColorBackground,
          elevation: 0,
          iconTheme: IconThemeData(
            color: kColorText,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kColorSurface2,
          contentTextStyle: TextStyle(
            color: kColorText,
          ),
        ),
      ),
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
