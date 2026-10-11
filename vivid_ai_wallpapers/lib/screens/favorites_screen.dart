import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/wallpaper_card.dart';
import 'wallpaper_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Wallpaper> wallpapers;
  final Function(String wallpaperId) onToggleLike;
  final VoidCallback onOpenSettings;
  final VoidCallback onExploreMore;
  final bool isDark;

  const FavoritesScreen({
    super.key,
    required this.wallpapers,
    required this.onToggleLike,
    required this.onOpenSettings,
    required this.onExploreMore,
    this.isDark = false,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLiked = widget.wallpapers.where((w) => w.isLiked).toList();
    final likedWallpapers = _searchQuery.isEmpty
        ? allLiked
        : allLiked
            .where((w) =>
                w.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                w.category.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: widget.isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Unified Top Bar
            AppTopBar(
              title: 'Favorites',
              isDark: widget.isDark,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: 'Search favorites...',
              onSearchSubmitted: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              onToggleSearch: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
              onOpenSettings: widget.onOpenSettings,
              trailing: allLiked.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${allLiked.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ).toSliver(),

            // Content
            if (likedWallpapers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: widget.isDark ? AppColors.darkCard : AppColors.pillBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          AmazingIconOutlined.heart,
                          size: 48,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _searchQuery.isNotEmpty ? 'No Matching Favorites' : 'No Favorites Yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try searching with a different term'
                            : 'Tap the heart on any wallpaper to add it here',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 24),
                        BouncingWrapper(
                          lowerBound: 0.94,
                          onTap: widget.onExploreMore,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Discover Wallpapers',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wp = likedWallpapers[index];
                      return WallpaperCard(
                        wallpaper: wp,
                        isDark: widget.isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WallpaperDetailScreen(
                                wallpaper: wp,
                                onToggleLike: widget.onToggleLike,
                                isDark: widget.isDark,
                              ),
                            ),
                          );
                        },
                        onLikeToggle: () => widget.onToggleLike(wp.id),
                      );
                    },
                    childCount: likedWallpapers.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
