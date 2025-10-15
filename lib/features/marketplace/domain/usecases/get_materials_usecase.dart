import 'package:fpdart/fpdart.dart';
import '../entities/educational_material.dart';
import '../entities/filter_options.dart';
import '../repositories/marketplace_repository.dart';
import '../../data/repositories/mock_marketplace_repository.dart';

class GetMaterialsUseCase {
  final MarketplaceRepository _repository;

  GetMaterialsUseCase(this._repository);

  Future<Either<String, List<EducationalMaterial>>> call({
    FilterOptions? filters,
    int page = 1,
    int limit = 20,
  }) async {
    return await _repository.getMaterials(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  // Mock конструктор для тестирования
  GetMaterialsUseCase._mock() : _repository = MockMarketplaceRepository();
}
