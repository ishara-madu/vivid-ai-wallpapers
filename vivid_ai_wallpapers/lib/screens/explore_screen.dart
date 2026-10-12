import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/category_pill.dart';
import '../widgets/wallpaper_card.dart';
import 'wallpaper_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final List<Wallpaper> wallpapers;
  final List<String> categories;
  final Function(String wallpaperId) onToggleLike;
  final VoidCallback onOpenSettings;
  final CutoutType selectedCutout;
  final VoidCallback onOpenCutoutSelector;
  final Future<void> Function()? onRefresh;
  final bool isDark;

  const ExploreScreen({
    super.key,
    required this.wallpapers,
    required this.categories,
    required this.onToggleLike,
    required this.onOpenSettings,
    required this.selectedCutout,
    required this.onOpenCutoutSelector,
    this.onRefresh,
    this.isDark = false,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'For You';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Wallpaper> get _filteredWallpapers {
    // 1. Filter by category
    List<Wallpaper> list;
    if (_selectedCategory == 'For You') {
      // Prioritize wallpapers matching the user's camera cutout
      list = widget.wallpapers
          .where((w) => w.cutoutType == widget.selectedCutout)
          .toList();
      if (list.isEmpty) {
        list = widget.wallpapers.toList();
      }
    } else if (_selectedCategory == 'Center Hole') {
      list = widget.wallpapers
          .where((w) => w.cutoutType == CutoutType.centerHole)
          .toList();
    } else if (_selectedCategory == 'Dynamic Island') {
      list = widget.wallpapers
          .where((w) => w.cutoutType == CutoutType.dynamicIsland)
          .toList();
    } else if (_selectedCategory == 'Left Corner') {
      list = widget.wallpapers
          .where((w) => w.cutoutType == CutoutType.leftHole)
          .toList();
    } else if (_selectedCategory == 'AMOLED Stealth') {
      list = widget.wallpapers
          .where((w) => w.cutoutType == CutoutType.universal)
          .toList();
    } else if (_selectedCategory == 'Creative Cutouts') {
      list = widget.wallpapers
          .where((w) => w.category == 'Creative Cutouts')
          .toList();
    } else {
      // 'All': sort user's cutout to the front
      list = List<Wallpaper>.from(widget.wallpapers);
      list.sort((a, b) {
        final aMatch = a.cutoutType == widget.selectedCutout ? 0 : 1;
        final bMatch = b.cutoutType == widget.selectedCutout ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });
    }

    // 2. Filter by search query if any
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((w) {
        return w.title.toLowerCase().contains(q) ||
            w.category.toLowerCase().contains(q) ||
            w.cutoutType.displayName.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? AppColors.darkBackground
          : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryPurple,
          onRefresh: widget.onRefresh ?? () async {},
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Unified Top Bar
              AppTopBar(
                title: 'Explore',
                isDark: widget.isDark,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: 'Search notch wallpapers...',
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
            ).toSliver(),

            // Cutout Device Bar (Shows active cutout + quick tap to change)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: BouncingWrapper(
                  lowerBound: 0.96,
                  onTap: widget.onOpenCutoutSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkCard
                          : AppColors.pillBackground.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AmazingIconOutlined.mobile,
                            size: 14,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: widget.isDark ? Colors.white70 : AppColors.textDark,
                              ),
                              children: [
                                const TextSpan(text: 'Tuned for: '),
                                TextSpan(
                                  text: widget.selectedCutout.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Change',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                AmazingIconOutlined.arrowRight2,
                                size: 12,
                                color: AppColors.primaryPurple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal Category Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    final isSelected = category == _selectedCategory;
                    return CategoryPill(
                      title: category,
                      isSelected: isSelected,
                      isDark: widget.isDark,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Wallpapers Grid (2 columns)
            _filteredWallpapers.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No wallpapers found for this cutout style.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final wallpaper = _filteredWallpapers[index];
                          return WallpaperCard(
                            wallpaper: wallpaper,
                            isDark: widget.isDark,
                            onLikeToggle: () =>
                                widget.onToggleLike(wallpaper.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WallpaperDetailScreen(
                                    wallpaper: wallpaper,
                                    onToggleLike: widget.onToggleLike,
                                    isDark: widget.isDark,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: _filteredWallpapers.length,
                      ),
                    ),
                  ),

            // Bottom space for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    ),
  );
}
}
