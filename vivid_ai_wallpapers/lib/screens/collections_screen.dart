import 'package:flutter/material.dart';
import 'package:amazing_icons/amazing_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bouncing_wrapper.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  final List<WallpaperCollection> collections;
  final Function(String wallpaperId) onToggleLike;
  final VoidCallback onOpenSettings;
  final bool isDark;

  const CollectionsScreen({
    super.key,
    required this.collections,
    required this.onToggleLike,
    required this.onOpenSettings,
    this.isDark = false,
  });

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCollections = _searchQuery.isEmpty
        ? widget.collections
        : widget.collections
            .where((c) =>
                c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: widget.isDark
          ? AppColors.darkBackground
          : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Unified Top Bar
            AppTopBar(
              title: 'Collections',
              isDark: widget.isDark,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: 'Search collections...',
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

            // Featured Carousel (Gazeful Landscapes - as seen in Image 2)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 440,
                child: filteredCollections.isEmpty
                    ? Center(
                        child: Text(
                          'No collections found',
                          style: GoogleFonts.poppins(color: AppColors.textMuted),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredCollections.length,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentPage = idx;
                          });
                        },
                        itemBuilder: (context, index) {
                          final col = filteredCollections[index];
                          return _buildFeaturedCard(col);
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Carousel Progress Bar Indicator (Slider line seen in Image 2)
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.pillBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedAlign(
                          alignment: _currentPage == 0
                              ? Alignment.centerLeft
                              : (_currentPage == 1
                                  ? Alignment.center
                                  : Alignment.centerRight),
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // "All Categories & Collections" Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'More Collections',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // List of Collection Rows
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final col = widget.collections[index];
                    return _buildCollectionRow(col);
                  },
                  childCount: widget.collections.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(WallpaperCollection col) {
    return BouncingWrapper(
      lowerBound: 0.96,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailScreen(
              collection: col,
              onToggleLike: widget.onToggleLike,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: col.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: col.gradientColors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              col.coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: col.gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Subtle Gradient Shadow at Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom Content Overlay
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    col.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Wallpaper Count Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          AmazingIconOutlined.gallery,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${col.wallpaperCount} wallpapers',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionRow(WallpaperCollection col) {
    return BouncingWrapper(
      lowerBound: 0.96,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailScreen(
              collection: col,
              onToggleLike: widget.onToggleLike,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: col.gradientColors),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                col.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    col.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${col.wallpaperCount} wallpapers • ${col.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AmazingIconOutlined.arrowRight2,
              size: 16,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
