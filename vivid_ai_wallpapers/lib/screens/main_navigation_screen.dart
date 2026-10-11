import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/sample_wallpapers.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/cutout_setup_dialog.dart';
import '../widgets/floating_bottom_nav.dart';
import 'collections_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDark;

  const MainNavigationScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDark,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late List<Wallpaper> _wallpapers;
  late List<WallpaperCollection> _collections;
  late List<String> _categories;
  CutoutType _selectedCutout = CutoutType.centerHole;

  @override
  void initState() {
    super.initState();
    _wallpapers = SampleData.wallpapers;
    _collections = SampleData.collections;
    _categories = SampleData.categories;

    // Show initial visual cutout setup modal when app launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptCutoutSetup();
    });
  }

  void _promptCutoutSetup() {
    CutoutSetupDialog.show(
      context: context,
      currentCutout: _selectedCutout,
      isDark: widget.isDark,
      onSelect: (type) {
        setState(() {
          _selectedCutout = type;
        });
      },
    );
  }

  void _toggleLike(String wallpaperId) {
    setState(() {
      final index = _wallpapers.indexWhere((w) => w.id == wallpaperId);
      if (index != -1) {
        _wallpapers[index].isLiked = !_wallpapers[index].isLiked;
      }
    });
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'V',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vivid Notch AI',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Custom Cutout & Notch Wallpaper Engine',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Camera Cutout Selection Tile
              BouncingWrapper(
                lowerBound: 0.96,
                onTap: () {
                  Navigator.pop(context);
                  _promptCutoutSetup();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.darkCard
                        : AppColors.pillBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            AmazingIconOutlined.mobile,
                            color: AppColors.primaryPurple,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Camera Cutout Style',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                              Text(
                                _selectedCutout.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        AmazingIconOutlined.arrowRight2,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Dark Mode Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.darkCard
                      : AppColors.pillBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.isDark
                              ? AmazingIconFilled.moon
                              : AmazingIconFilled.sun,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dark Mode',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: widget.isDark
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: widget.isDark,
                      activeColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        widget.onThemeChanged(val);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? AppColors.darkBackground
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Screen Switcher
          IndexedStack(
            index: _currentIndex,
            children: [
              ExploreScreen(
                wallpapers: _wallpapers,
                categories: _categories,
                selectedCutout: _selectedCutout,
                onOpenCutoutSelector: _promptCutoutSetup,
                onToggleLike: _toggleLike,
                onOpenSettings: _openSettingsSheet,
                isDark: widget.isDark,
              ),
              CollectionsScreen(
                collections: _collections,
                onToggleLike: _toggleLike,
                onOpenSettings: _openSettingsSheet,
                isDark: widget.isDark,
              ),
              FavoritesScreen(
                wallpapers: _wallpapers,
                onToggleLike: _toggleLike,
                onOpenSettings: _openSettingsSheet,
                onExploreMore: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                isDark: widget.isDark,
              ),
            ],
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentIndex,
              isDark: widget.isDark,
              onTabSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
