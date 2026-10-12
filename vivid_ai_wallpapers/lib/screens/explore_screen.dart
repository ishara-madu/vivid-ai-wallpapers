import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/category_pill.dart';
import '../widgets/offline_indicator.dart';
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
  final VoidCallback? onRetry;
  final bool isLoading;
  final bool isOffline;
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
    this.onRetry,
    this.isLoading = false,
    this.isOffline = false,
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
    } else if (_selectedCategory == 'All') {
      // 'All': sort user's cutout to the front
      list = List<Wallpaper>.from(widget.wallpapers);
      list.sort((a, b) {
        final aMatch = a.cutoutType == widget.selectedCutout ? 0 : 1;
        final bMatch = b.cutoutType == widget.selectedCutout ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });
    } else {
      // Filter dynamically by artistic category
      final targetCat = _selectedCategory.toLowerCase().trim();
      list = widget.wallpapers.where((w) {
        final cat = w.category.toLowerCase().trim();
        return cat == targetCat || cat.contains(targetCat) || targetCat.contains(cat);
      }).toList();
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

            // Offline Banner when data is off but previous wallpapers exist
            if (widget.isOffline && widget.wallpapers.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF523B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFF523B).withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          AmazingIconOutlined.wifiSquare,
                          color: Color(0xFFFF523B),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No internet connection. Turn on Mobile Data or Wi-Fi to load new wallpapers.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                        if (widget.onRetry != null)
                          GestureDetector(
                            onTap: widget.onRetry,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF523B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Horizontal Category Pills
            if (widget.wallpapers.isNotEmpty)
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

            if (widget.wallpapers.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Body: Offline / Loading / Empty Catalog / Wallpapers Grid
            if (widget.isOffline && widget.wallpapers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: OfflineIndicator(
                  isDark: widget.isDark,
                  isRetrying: widget.isLoading,
                  onRetry: widget.onRetry ?? () {},
                ),
              )
            else if (widget.isLoading && widget.wallpapers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Loading Wallpapers...',
                        style: GoogleFonts.poppins(
                          color: widget.isDark ? Colors.white : AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Connecting to repository catalog...',
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.wallpapers.isEmpty)
              // Online, but repository catalog has no wallpapers yet
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.darkCard : AppColors.pillBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              AmazingIconOutlined.image,
                              size: 40,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'No Wallpapers Found',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The wallpaper catalog is currently empty. Upload wallpapers via the Web Uploader to view them here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BouncingWrapper(
                          lowerBound: 0.94,
                          onTap: widget.onRefresh,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  AmazingIconOutlined.refresh2,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Refresh Catalog',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_filteredWallpapers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AmazingIconOutlined.searchNormal,
                          size: 44,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Wallpapers Found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No wallpapers match "$_selectedCategory".',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
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
