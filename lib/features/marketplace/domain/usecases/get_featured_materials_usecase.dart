import 'package:fpdart/fpdart.dart';
import '../entities/educational_material.dart';
import '../repositories/marketplace_repository.dart';
import '../../data/repositories/mock_marketplace_repository.dart';

class GetFeaturedMaterialsUseCase {
  final MarketplaceRepository _repository;

  GetFeaturedMaterialsUseCase(this._repository);

  Future<Either<String, List<EducationalMaterial>>> call() async {
    return await _repository.getFeaturedMaterials();
  }

  // Mock конструктор для тестирования
  GetFeaturedMaterialsUseCase._mock() : _repository = MockMarketplaceRepository();
}
