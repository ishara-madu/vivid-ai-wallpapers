import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/sample_wallpapers.dart';
import '../models/wallpaper.dart';

class WallpaperService {
  static const String catalogUrl =
      'https://raw.githubusercontent.com/ishara-madu/vivid-ai-wallpapers/main/wallpapers/metadata/catalog.json';

  /// Fetches live wallpapers from GitHub catalog.json.
  /// Falls back to SampleData on network error or offline.
  static Future<List<Wallpaper>> fetchLiveWallpapers() async {
    try {
      // Add cache-buster timestamp to ensure GitHub CDN immediately delivers newly pushed wallpapers
      final uri = Uri.parse('$catalogUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final liveList = <Wallpaper>[];

        for (final item in jsonList) {
          try {
            if (item is Map<String, dynamic>) {
              liveList.add(Wallpaper.fromJson(item));
            }
          } catch (e) {
            debugPrint('Error parsing wallpaper item: $e');
          }
        }

        if (liveList.isNotEmpty) {
          // Return live catalog directly from the repository
          return liveList;
        }
      }
    } catch (e) {
      debugPrint('Notice: Could not fetch live catalog ($e). Using sample data.');
    }

    return SampleData.wallpapers;
  }
}
