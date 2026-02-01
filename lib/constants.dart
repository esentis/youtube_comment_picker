import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kColorBackground = Color(0xFF0B0D10);
const Color kColorSurface = Color(0xFF141820);
const Color kColorSurface2 = Color(0xFF1A2028);
const Color kColorBorder = Color(0xFF2A3038);
const Color kColorText = Color(0xFFF2F4F7);
const Color kColorTextMuted = Color(0xFF9AA3AE);
const Color kColorRedYtb = Color(0xFFE83A3A);
const Color kColorGreyYtb = kColorSurface2;

InputDecoration kInputDecoration({required String labeText}) => InputDecoration(
      labelText: labeText,
      hintText: labeText,
      filled: true,
      fillColor: kColorSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      labelStyle: const TextStyle(
        color: kColorTextMuted,
      ),
      floatingLabelStyle: const TextStyle(
        color: kColorText,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: kColorBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: kColorRedYtb,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: kColorBorder,
        ),
      ),
    );
Future<void> kLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch');
  }
}
