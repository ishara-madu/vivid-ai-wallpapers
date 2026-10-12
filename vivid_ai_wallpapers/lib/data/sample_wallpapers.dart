import '../models/wallpaper.dart';

class SampleData {
  /// All wallpapers are now loaded 100% dynamically from GitHub repository catalog.json.
  /// Hardcoded sample wallpapers have been completely removed.
  static List<Wallpaper> get wallpapers => const [];

  /// Collections are dynamically generated based on active repository wallpapers.
  static List<WallpaperCollection> get collections => const [];

  static const List<String> categories = [
    'For You',
    'Creative Cutouts',
    'AMOLED & Stealth',
    'Cyberpunk & Sci-Fi',
    'Abstract & 3D',
    'Minimal & Vector',
    'Nature & Landscapes',
    'Anime & Gaming',
    'Vibrant Flows',
    'All',
  ];
}
