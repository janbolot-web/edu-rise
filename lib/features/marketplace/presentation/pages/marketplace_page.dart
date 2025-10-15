import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/featured_materials_section.dart';
import '../widgets/materials_grid.dart';
import '../widgets/marketplace_filters.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../../data/seed_data.dart';
import 'material_details_page.dart';
import 'add_material_page.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  bool _showActions = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more materials
      ref.read(marketplaceViewModelProvider.notifier).loadMoreMaterials();
    }

    // Hide/show actions based on scroll position
    final shouldShowActions = _scrollController.position.pixels < 50;
    if (shouldShowActions != _showActions) {
      setState(() {
        _showActions = shouldShowActions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceViewModelProvider);

    return Scaffold(
      backgroundColor: appBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMaterialPage(),
            ),
          );
        },
        backgroundColor: appAccentEnd,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Добавить материал',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Маркетплейс',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: appPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      appBackground,
                    ],
                  ),
                ),
              ),
            ),
            actions: _showActions ? [
              // DEV ONLY: Seed data button
              IconButton(
                onPressed: () async {
                  final scaffold = ScaffoldMessenger.of(context);
                  try {
                    scaffold.showSnackBar(
                      const SnackBar(content: Text('🌱 Загрузка тестовых данных...')),
                    );
                    await MarketplaceSeedData.seedSampleData();
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Данные успешно загружены!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the list
                    ref.read(marketplaceViewModelProvider.notifier).refresh();
                  } catch (e) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text('❌ Ошибка: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.cloud_upload, color: Colors.green),
                tooltip: 'Загрузить тестовые данные',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: appPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement search
                },
                icon: Icon(Icons.search, color: appPrimary),
              ),
            ] : null,
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MarketplaceSearchBar(
                onSearchChanged: (query) {
                  ref.read(marketplaceViewModelProvider.notifier)
                      .updateSearchQuery(query);
                },
              ),
            ),
          ),

          // Filters
          if (_showFilters)
            SliverToBoxAdapter(
              child: MarketplaceFilters(
                onFiltersChanged: (filters) {
                  ref.read(marketplaceViewModelProvider.notifier)
                      .updateFilters(filters);
                },
              ),
            ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: appPrimary,
                unselectedLabelColor: appSecondary,
                indicatorColor: appAccentEnd,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Все'),
                  Tab(text: 'Презентации'),
                  Tab(text: 'Тесты'),
                  Tab(text: 'Конспекты'),
                ],
                onTap: (index) {
                  ref.read(marketplaceViewModelProvider.notifier)
                      .selectCategory(index);
                },
              ),
            ),
          ),

          // Featured Materials
          SliverToBoxAdapter(
            child: FeaturedMaterialsSection(
              materials: state.featuredMaterials,
              isLoading: state.isLoadingFeatured,
            ),
          ),

          // Materials Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Все материалы',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show all materials
                    },
                    child: Text(
                      'Показать все',
                      style: GoogleFonts.montserrat(
                        color: appAccentEnd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message
          if (state.error != null && state.materials.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: appPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: appSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(marketplaceViewModelProvider.notifier).refresh();
                      },
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              ),
            ),

          // Materials List
          MaterialsGrid(
            materials: state.materials,
            isLoading: state.isLoading,
            hasMore: state.hasMore,
            onMaterialTap: (material) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaterialDetailsPage(
                    materialId: material.id,
                  ),
                ),
              );
            },
            onFavoriteTap: (material) {
              // TODO: Toggle favorite
            },
          ),
        ],
      ),
    );
  }
}
