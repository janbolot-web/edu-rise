import 'package:freezed_annotation/freezed_annotation.dart';
import 'educational_material.dart';

part 'filter_options.freezed.dart';

@freezed
abstract class FilterOptions with _$FilterOptions {
  const factory FilterOptions({
    @Default([]) List<String> subjects,
    @Default([]) List<String> grades,
    @Default([]) List<MaterialType> types,
    @Default([]) List<MaterialDifficulty> difficulties,
    @Default(PriceRange()) PriceRange priceRange,
    @Default(RatingRange()) RatingRange ratingRange,
    @Default(false) bool freeOnly,
    @Default(false) bool featuredOnly,
    @Default('') String searchQuery,
    @Default(SortOption.newest) SortOption sortBy,
    @Default('') String language,
  }) = _FilterOptions;
}

@freezed
abstract class PriceRange with _$PriceRange {
  const factory PriceRange({
    @Default(0.0) double min,
    @Default(1000.0) double max,
  }) = _PriceRange;
}

@freezed
abstract class RatingRange with _$RatingRange {
  const factory RatingRange({
    @Default(0.0) double min,
    @Default(5.0) double max,
  }) = _RatingRange;
}

enum SortOption {
  @JsonValue('newest')
  newest,
  @JsonValue('oldest')
  oldest,
  @JsonValue('price_low')
  priceLow,
  @JsonValue('price_high')
  priceHigh,
  @JsonValue('rating')
  rating,
  @JsonValue('downloads')
  downloads,
  @JsonValue('popular')
  popular,
}
