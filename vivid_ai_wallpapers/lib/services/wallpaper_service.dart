import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class WallpaperService {
  static const String catalogUrl =
      'https://raw.githubusercontent.com/ishara-madu/vivid-ai-wallpapers/main/wallpapers/metadata/catalog.json';

  /// Fetches live wallpapers from GitHub catalog.json.
  /// Throws an exception if offline or network connection fails.
  static Future<List<Wallpaper>> fetchLiveWallpapers() async {
    // Add cache-buster timestamp to ensure GitHub CDN delivers latest pushed wallpapers
    final uri = Uri.parse('$catalogUrl?t=${DateTime.now().millisecondsSinceEpoch}');
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10));

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

      return liveList;
    } else {
      throw Exception('Failed to load wallpapers (Status: ${response.statusCode})');
    }
  }
}
