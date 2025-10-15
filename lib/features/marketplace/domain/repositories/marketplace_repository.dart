import 'package:fpdart/fpdart.dart';
import '../entities/educational_material.dart';
import '../entities/review.dart';
import '../entities/filter_options.dart';

abstract class MarketplaceRepository {
  Future<Either<String, List<EducationalMaterial>>> getMaterials({
    FilterOptions? filters,
    int page = 1,
    int limit = 20,
  });

  Future<Either<String, EducationalMaterial>> getMaterialById(String id);
  
  Future<Either<String, List<EducationalMaterial>>> getFeaturedMaterials();
  
  Future<Either<String, List<EducationalMaterial>>> getRecommendedMaterials(String userId);
  
  Future<Either<String, List<EducationalMaterial>>> getMaterialsByAuthor(String authorId);
  
  Future<Either<String, List<Review>>> getMaterialReviews(String materialId);
  
  Future<Either<String, Review>> addReview(Review review);
  
  Future<Either<String, bool>> purchaseMaterial(String materialId, String userId);
  
  Future<Either<String, bool>> downloadMaterial(String materialId, String userId);
  
  Future<Either<String, List<String>>> getSubjects();
  
  Future<Either<String, List<String>>> getGrades();
  
  Future<Either<String, bool>> reportMaterial(String materialId, String reason);
}
