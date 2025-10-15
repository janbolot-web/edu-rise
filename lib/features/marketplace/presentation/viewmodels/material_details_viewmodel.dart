import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/educational_material.dart';
import '../../domain/entities/review.dart';
import '../../data/repositories/firestore_marketplace_repository.dart';

class MaterialDetailsState {
  final EducationalMaterial? material;
  final List<Review> reviews;
  final List<EducationalMaterial> similarMaterials;
  final bool isLoading;
  final bool isLoadingReviews;
  final String? error;
  final bool isFavorite;
  final bool isPurchased;

  const MaterialDetailsState({
    this.material,
    this.reviews = const [],
    this.similarMaterials = const [],
    this.isLoading = false,
    this.isLoadingReviews = false,
    this.error,
    this.isFavorite = false,
    this.isPurchased = false,
  });

  MaterialDetailsState copyWith({
    EducationalMaterial? material,
    List<Review>? reviews,
    List<EducationalMaterial>? similarMaterials,
    bool? isLoading,
    bool? isLoadingReviews,
    String? error,
    bool? isFavorite,
    bool? isPurchased,
  }) {
    return MaterialDetailsState(
      material: material ?? this.material,
      reviews: reviews ?? this.reviews,
      similarMaterials: similarMaterials ?? this.similarMaterials,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

// Provider для получения данных материала
final materialDetailsProvider = FutureProvider.family<EducationalMaterial, String>((ref, materialId) async {
  print('🔍 [MaterialDetails] Loading material: $materialId');
  final repository = FirestoreMarketplaceRepository();
  final result = await repository.getMaterialById(materialId);
  
  return result.fold(
    (error) {
      print('❌ [MaterialDetails] Error: $error');
      throw Exception(error);
    },
    (material) {
      print('✅ [MaterialDetails] Loaded: ${material.title}');
      return material;
    },
  );
});

// Provider для отзывов
final materialReviewsProvider = FutureProvider.family<List<Review>, String>((ref, materialId) async {
  final repository = FirestoreMarketplaceRepository();
  final result = await repository.getMaterialReviews(materialId);
  
  return result.fold(
    (error) => [],
    (reviews) => reviews,
  );
});

// Provider для похожих материалов  
final similarMaterialsProvider = FutureProvider.family<List<EducationalMaterial>, String>((ref, subject) async {
  final repository = FirestoreMarketplaceRepository();
  final result = await repository.getMaterials(limit: 4);
  
  return result.fold(
    (error) => [],
    (materials) => materials.where((m) => m.subject == subject).take(4).toList(),
  );
});
