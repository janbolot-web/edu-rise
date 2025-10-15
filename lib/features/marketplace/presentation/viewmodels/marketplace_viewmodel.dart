import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/educational_material.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/usecases/get_materials_usecase.dart';
import '../../domain/usecases/get_featured_materials_usecase.dart';
import '../../data/repositories/firestore_marketplace_repository.dart';

class MarketplaceState {
  final List<EducationalMaterial> materials;
  final List<EducationalMaterial> featuredMaterials;
  final FilterOptions filters;
  final bool isLoading;
  final bool isLoadingFeatured;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final int selectedCategory;

  const MarketplaceState({
    this.materials = const [],
    this.featuredMaterials = const [],
    this.filters = const FilterOptions(),
    this.isLoading = false,
    this.isLoadingFeatured = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.selectedCategory = 0,
  });

  MarketplaceState copyWith({
    List<EducationalMaterial>? materials,
    List<EducationalMaterial>? featuredMaterials,
    FilterOptions? filters,
    bool? isLoading,
    bool? isLoadingFeatured,
    bool? hasMore,
    String? error,
    int? currentPage,
    int? selectedCategory,
  }) {
    return MarketplaceState(
      materials: materials ?? this.materials,
      featuredMaterials: featuredMaterials ?? this.featuredMaterials,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class MarketplaceViewModel extends Notifier<MarketplaceState> {
  final GetMaterialsUseCase _getMaterialsUseCase;
  final GetFeaturedMaterialsUseCase _getFeaturedMaterialsUseCase;

  MarketplaceViewModel(this._getMaterialsUseCase, this._getFeaturedMaterialsUseCase);

  @override
  MarketplaceState build() {
    Future.microtask(() => _loadInitialData());
    return const MarketplaceState();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadFeaturedMaterials(),
      loadMaterials(),
    ]);
  }

  Future<void> loadMaterials() async {
    if (state.isLoading) return;

    print('🔍 [Marketplace] Loading materials, page: ${state.currentPage}');
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getMaterialsUseCase(
      filters: state.filters,
      page: state.currentPage,
    );

    result.fold(
      (error) {
        print('❌ [Marketplace] Error loading materials: $error');
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
      },
      (newMaterials) {
        print('✅ [Marketplace] Loaded ${newMaterials.length} materials');
        state = state.copyWith(
          isLoading: false,
          materials: state.currentPage == 1 
              ? newMaterials 
              : [...state.materials, ...newMaterials],
          hasMore: newMaterials.length >= 20,
        );
      },
    );
  }

  Future<void> loadFeaturedMaterials() async {
    print('🔍 [Marketplace] Loading featured materials');
    state = state.copyWith(isLoadingFeatured: true);

    final result = await _getFeaturedMaterialsUseCase();

    result.fold(
      (error) {
        print('❌ [Marketplace] Error loading featured: $error');
        state = state.copyWith(
          isLoadingFeatured: false,
          error: error,
        );
      },
      (featuredMaterials) {
        print('✅ [Marketplace] Loaded ${featuredMaterials.length} featured materials');
        state = state.copyWith(
          isLoadingFeatured: false,
          featuredMaterials: featuredMaterials,
        );
      },
    );
  }

  Future<void> loadMoreMaterials() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadMaterials();
  }

  void updateFilters(FilterOptions filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      materials: [],
    );
    loadMaterials();
  }

  void updateSearchQuery(String query) {
    // Avoid calling generated `copyWith` in case Freezed codegen artifacts are missing.
    // Read existing values via `dynamic` safely and construct a new FilterOptions.
    final dyn = state.filters as dynamic;
    List<String> subjects = [];
    List<String> grades = [];
    List<MaterialType> types = [];
    List<MaterialDifficulty> difficulties = [];
    PriceRange priceRange = const PriceRange();
    RatingRange ratingRange = const RatingRange();
    bool freeOnly = false;
    bool featuredOnly = false;
    SortOption sortBy = SortOption.newest;
    String language = '';

    try { subjects = List<String>.from(dyn.subjects ?? []); } catch (_) {}
    try { grades = List<String>.from(dyn.grades ?? []); } catch (_) {}
    try { types = List<MaterialType>.from(dyn.types ?? []); } catch (_) {}
    try { difficulties = List<MaterialDifficulty>.from(dyn.difficulties ?? []); } catch (_) {}
    try { priceRange = dyn.priceRange as PriceRange; } catch (_) {}
    try { ratingRange = dyn.ratingRange as RatingRange; } catch (_) {}
    try { freeOnly = dyn.freeOnly as bool; } catch (_) {}
    try { featuredOnly = dyn.featuredOnly as bool; } catch (_) {}
    try { sortBy = dyn.sortBy as SortOption; } catch (_) {}
    try { language = dyn.language as String; } catch (_) {}

    final newFilters = FilterOptions(
      subjects: subjects,
      grades: grades,
      types: types,
      difficulties: difficulties,
      priceRange: priceRange,
      ratingRange: ratingRange,
      freeOnly: freeOnly,
      featuredOnly: featuredOnly,
      searchQuery: query,
      sortBy: sortBy,
      language: language,
    );

    updateFilters(newFilters);
  }

  void selectCategory(int category) {
    state = state.copyWith(selectedCategory: category);
    // TODO: Update filters based on category
    loadMaterials();
  }

  void refresh() {
    state = state.copyWith(
      currentPage: 1,
      materials: [],
      featuredMaterials: [],
    );
    _loadInitialData();
  }
}

final _firestoreRepository = FirestoreMarketplaceRepository();

final marketplaceViewModelProvider = NotifierProvider<MarketplaceViewModel, MarketplaceState>(() {
  return MarketplaceViewModel(
    GetMaterialsUseCase(_firestoreRepository),
    GetFeaturedMaterialsUseCase(_firestoreRepository),
  );
});
