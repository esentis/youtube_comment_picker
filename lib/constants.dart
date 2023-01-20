import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Color kColorRedYtb = const Color(0xffE83020);

InputDecoration kInputDecoration({required String labeText}) => InputDecoration(
      focusColor: Colors.red,
      labelStyle: TextStyle(
        color: kColorRedYtb.withOpacity(0.5),
      ),
      label: Text(labeText),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: kColorRedYtb.withOpacity(0.3),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: kColorRedYtb,
          width: 3,
        ),
      ),
    );
Future<void> kLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch');
  }
}
