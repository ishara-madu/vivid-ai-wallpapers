import 'package:flutter/material.dart';

enum CutoutType {
  centerHole,
  dynamicIsland,
  leftHole,
  universal;

  String get displayName => switch (this) {
    CutoutType.centerHole => 'Center Hole',
    CutoutType.dynamicIsland => 'Dynamic Island',
    CutoutType.leftHole => 'Left Corner',
    CutoutType.universal => 'Universal Stealth',
  };

  String get subtitle => switch (this) {
    CutoutType.centerHole => 'Samsung Galaxy, Xiaomi, Pixel, Nothing',
    CutoutType.dynamicIsland => 'iPhone 14-16 Pro, Honor Magic Pill',
    CutoutType.leftHole => 'OnePlus, Realme, older Galaxy',
    CutoutType.universal => 'Seamless dark fade for any display',
  };

  static CutoutType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'centerhole' || 'center_hole' || 'center' => CutoutType.centerHole,
      'dynamicisland' || 'dynamic_island' || 'island' || 'pill' => CutoutType.dynamicIsland,
      'lefthole' || 'left_hole' || 'left' => CutoutType.leftHole,
      _ => CutoutType.universal,
    };
  }
}

class Wallpaper {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final CutoutType cutoutType;
  final bool isMultivariant;
  final List<String> variants;
  final Map<String, String> cutoutVariants;
  final List<Color> gradientFallback;
  final String resolution;
  final int views;
  bool isLiked;
  final String uploadDate;
  final String description;
  final String dimensions;
  final String aiEngine;

  Wallpaper({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    this.cutoutType = CutoutType.centerHole,
    this.isMultivariant = false,
    this.variants = const [],
    this.cutoutVariants = const {},
    this.gradientFallback = const [Color(0xFF632FE1), Color(0xFFFF685F)],
    this.resolution = '4K UHD',
    this.views = 1240,
    this.isLiked = false,
    this.uploadDate = 'Oct 10, 2026',
    this.description = 'A breathtaking AI-synthesized visual masterwork crafted with ultra-precise geometry and luminous color gradients.',
    this.dimensions = '2160 x 3840',
    this.aiEngine = 'Vivid AI Engine v3.4',
  });

  Wallpaper copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? category,
    CutoutType? cutoutType,
    bool? isMultivariant,
    List<String>? variants,
    Map<String, String>? cutoutVariants,
    List<Color>? gradientFallback,
    String? resolution,
    int? views,
    bool? isLiked,
    String? uploadDate,
    String? description,
    String? dimensions,
    String? aiEngine,
  }) {
    return Wallpaper(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      cutoutType: cutoutType ?? this.cutoutType,
      isMultivariant: isMultivariant ?? this.isMultivariant,
      variants: variants ?? this.variants,
      cutoutVariants: cutoutVariants ?? this.cutoutVariants,
      gradientFallback: gradientFallback ?? this.gradientFallback,
      resolution: resolution ?? this.resolution,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      dimensions: dimensions ?? this.dimensions,
      aiEngine: aiEngine ?? this.aiEngine,
    );
  }

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    List<Color> parseGradients(dynamic list) {
      if (list is List) {
        return list.map((c) {
          if (c is String) {
            final hex = c.replaceFirst('#', '');
            if (hex.length == 6) {
              return Color(int.parse('FF$hex', radix: 16));
            } else if (hex.length == 8) {
              return Color(int.parse(hex, radix: 16));
            }
          } else if (c is int) {
            return Color(c);
          }
          return const Color(0xFF632FE1);
        }).toList();
      }
      return const [Color(0xFF632FE1), Color(0xFFFF685F)];
    }

    Map<String, String> parseCutoutVariants(dynamic map) {
      if (map is Map) {
        return map.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return const {};
    }

    final rawVariants = (json['variants'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final cutoutVariantsMap = parseCutoutVariants(json['cutoutVariants']);

    return Wallpaper(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'Creative Cutouts',
      cutoutType: CutoutType.fromString(json['cutoutType'] as String?),
      isMultivariant: (json['isMultivariant'] as bool? ?? false) ||
          rawVariants.isNotEmpty ||
          cutoutVariantsMap.isNotEmpty,
      variants: rawVariants,
      cutoutVariants: cutoutVariantsMap,
      gradientFallback: parseGradients(json['gradientFallback']),
      resolution: json['resolution'] as String? ?? '4K Ultra HD',
      views: json['views'] as int? ?? 100,
      isLiked: json['isLiked'] as bool? ?? false,
      uploadDate: json['uploadDate'] as String? ?? 'Recently added',
      description: json['description'] as String? ?? '',
      dimensions: json['dimensions'] as String? ?? '2160 x 3840',
      aiEngine: json['aiEngine'] as String? ?? 'Vivid AI Engine',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'category': category,
      'cutoutType': cutoutType.name,
      'isMultivariant': isMultivariant,
      'variants': variants,
      'cutoutVariants': cutoutVariants,
      'gradientFallback': gradientFallback
          .map((c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}')
          .toList(),
      'resolution': resolution,
      'views': views,
      'isLiked': isLiked,
      'uploadDate': uploadDate,
      'description': description,
      'dimensions': dimensions,
      'aiEngine': aiEngine,
    };
  }
}

class WallpaperCollection {
  final String id;
  final String title;
  final String subtitle;
  final int wallpaperCount;
  final String coverImageUrl;
  final List<Color> gradientColors;
  final bool isDarkTheme;
  final List<Wallpaper> wallpapers;

  WallpaperCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.wallpaperCount,
    required this.coverImageUrl,
    required this.gradientColors,
    this.isDarkTheme = false,
    this.wallpapers = const [],
  });

  factory WallpaperCollection.fromJson(Map<String, dynamic> json) {
    List<Color> parseGradients(dynamic list) {
      if (list is List) {
        return list.map((c) {
          if (c is String) {
            final hex = c.replaceFirst('#', '');
            if (hex.length == 6) {
              return Color(int.parse('FF$hex', radix: 16));
            } else if (hex.length == 8) {
              return Color(int.parse(hex, radix: 16));
            }
          }
          return const Color(0xFF632FE1);
        }).toList();
      }
      return const [Color(0xFF632FE1), Color(0xFFFF685F)];
    }

    final rawWallpapers = json['wallpapers'] as List<dynamic>? ?? [];
    return WallpaperCollection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      wallpaperCount: json['wallpaperCount'] as int? ?? rawWallpapers.length,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      gradientColors: parseGradients(json['gradientColors']),
      isDarkTheme: json['isDarkTheme'] as bool? ?? false,
      wallpapers: rawWallpapers
          .map((w) => Wallpaper.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'wallpaperCount': wallpaperCount,
      'coverImageUrl': coverImageUrl,
      'gradientColors': gradientColors
          .map((c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}')
          .toList(),
      'isDarkTheme': isDarkTheme,
      'wallpapers': wallpapers.map((w) => w.toJson()).toList(),
    };
  }
}
