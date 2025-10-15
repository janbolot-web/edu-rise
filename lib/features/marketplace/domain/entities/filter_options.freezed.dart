// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilterOptions {

 List<String> get subjects; List<String> get grades; List<MaterialType> get types; List<MaterialDifficulty> get difficulties; PriceRange get priceRange; RatingRange get ratingRange; bool get freeOnly; bool get featuredOnly; String get searchQuery; SortOption get sortBy; String get language;
/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterOptionsCopyWith<FilterOptions> get copyWith => _$FilterOptionsCopyWithImpl<FilterOptions>(this as FilterOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterOptions&&const DeepCollectionEquality().equals(other.subjects, subjects)&&const DeepCollectionEquality().equals(other.grades, grades)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.difficulties, difficulties)&&(identical(other.priceRange, priceRange) || other.priceRange == priceRange)&&(identical(other.ratingRange, ratingRange) || other.ratingRange == ratingRange)&&(identical(other.freeOnly, freeOnly) || other.freeOnly == freeOnly)&&(identical(other.featuredOnly, featuredOnly) || other.featuredOnly == featuredOnly)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(subjects),const DeepCollectionEquality().hash(grades),const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(difficulties),priceRange,ratingRange,freeOnly,featuredOnly,searchQuery,sortBy,language);

@override
String toString() {
  return 'FilterOptions(subjects: $subjects, grades: $grades, types: $types, difficulties: $difficulties, priceRange: $priceRange, ratingRange: $ratingRange, freeOnly: $freeOnly, featuredOnly: $featuredOnly, searchQuery: $searchQuery, sortBy: $sortBy, language: $language)';
}


}

/// @nodoc
abstract mixin class $FilterOptionsCopyWith<$Res>  {
  factory $FilterOptionsCopyWith(FilterOptions value, $Res Function(FilterOptions) _then) = _$FilterOptionsCopyWithImpl;
@useResult
$Res call({
 List<String> subjects, List<String> grades, List<MaterialType> types, List<MaterialDifficulty> difficulties, PriceRange priceRange, RatingRange ratingRange, bool freeOnly, bool featuredOnly, String searchQuery, SortOption sortBy, String language
});


$PriceRangeCopyWith<$Res> get priceRange;$RatingRangeCopyWith<$Res> get ratingRange;

}
/// @nodoc
class _$FilterOptionsCopyWithImpl<$Res>
    implements $FilterOptionsCopyWith<$Res> {
  _$FilterOptionsCopyWithImpl(this._self, this._then);

  final FilterOptions _self;
  final $Res Function(FilterOptions) _then;

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subjects = null,Object? grades = null,Object? types = null,Object? difficulties = null,Object? priceRange = null,Object? ratingRange = null,Object? freeOnly = null,Object? featuredOnly = null,Object? searchQuery = null,Object? sortBy = null,Object? language = null,}) {
  return _then(_self.copyWith(
subjects: null == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>,grades: null == grades ? _self.grades : grades // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<MaterialType>,difficulties: null == difficulties ? _self.difficulties : difficulties // ignore: cast_nullable_to_non_nullable
as List<MaterialDifficulty>,priceRange: null == priceRange ? _self.priceRange : priceRange // ignore: cast_nullable_to_non_nullable
as PriceRange,ratingRange: null == ratingRange ? _self.ratingRange : ratingRange // ignore: cast_nullable_to_non_nullable
as RatingRange,freeOnly: null == freeOnly ? _self.freeOnly : freeOnly // ignore: cast_nullable_to_non_nullable
as bool,featuredOnly: null == featuredOnly ? _self.featuredOnly : featuredOnly // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortOption,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceRange {
  
  return $PriceRangeCopyWith<$Res>(_self.priceRange, (value) {
    return _then(_self.copyWith(priceRange: value));
  });
}/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingRangeCopyWith<$Res> get ratingRange {
  
  return $RatingRangeCopyWith<$Res>(_self.ratingRange, (value) {
    return _then(_self.copyWith(ratingRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [FilterOptions].
extension FilterOptionsPatterns on FilterOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilterOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilterOptions value)  $default,){
final _that = this;
switch (_that) {
case _FilterOptions():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilterOptions value)?  $default,){
final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> subjects,  List<String> grades,  List<MaterialType> types,  List<MaterialDifficulty> difficulties,  PriceRange priceRange,  RatingRange ratingRange,  bool freeOnly,  bool featuredOnly,  String searchQuery,  SortOption sortBy,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.subjects,_that.grades,_that.types,_that.difficulties,_that.priceRange,_that.ratingRange,_that.freeOnly,_that.featuredOnly,_that.searchQuery,_that.sortBy,_that.language);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> subjects,  List<String> grades,  List<MaterialType> types,  List<MaterialDifficulty> difficulties,  PriceRange priceRange,  RatingRange ratingRange,  bool freeOnly,  bool featuredOnly,  String searchQuery,  SortOption sortBy,  String language)  $default,) {final _that = this;
switch (_that) {
case _FilterOptions():
return $default(_that.subjects,_that.grades,_that.types,_that.difficulties,_that.priceRange,_that.ratingRange,_that.freeOnly,_that.featuredOnly,_that.searchQuery,_that.sortBy,_that.language);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> subjects,  List<String> grades,  List<MaterialType> types,  List<MaterialDifficulty> difficulties,  PriceRange priceRange,  RatingRange ratingRange,  bool freeOnly,  bool featuredOnly,  String searchQuery,  SortOption sortBy,  String language)?  $default,) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.subjects,_that.grades,_that.types,_that.difficulties,_that.priceRange,_that.ratingRange,_that.freeOnly,_that.featuredOnly,_that.searchQuery,_that.sortBy,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _FilterOptions implements FilterOptions {
  const _FilterOptions({final  List<String> subjects = const [], final  List<String> grades = const [], final  List<MaterialType> types = const [], final  List<MaterialDifficulty> difficulties = const [], this.priceRange = const PriceRange(), this.ratingRange = const RatingRange(), this.freeOnly = false, this.featuredOnly = false, this.searchQuery = '', this.sortBy = SortOption.newest, this.language = ''}): _subjects = subjects,_grades = grades,_types = types,_difficulties = difficulties;
  

 final  List<String> _subjects;
@override@JsonKey() List<String> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

 final  List<String> _grades;
@override@JsonKey() List<String> get grades {
  if (_grades is EqualUnmodifiableListView) return _grades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_grades);
}

 final  List<MaterialType> _types;
@override@JsonKey() List<MaterialType> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

 final  List<MaterialDifficulty> _difficulties;
@override@JsonKey() List<MaterialDifficulty> get difficulties {
  if (_difficulties is EqualUnmodifiableListView) return _difficulties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_difficulties);
}

@override@JsonKey() final  PriceRange priceRange;
@override@JsonKey() final  RatingRange ratingRange;
@override@JsonKey() final  bool freeOnly;
@override@JsonKey() final  bool featuredOnly;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  SortOption sortBy;
@override@JsonKey() final  String language;

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterOptionsCopyWith<_FilterOptions> get copyWith => __$FilterOptionsCopyWithImpl<_FilterOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterOptions&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&const DeepCollectionEquality().equals(other._grades, _grades)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._difficulties, _difficulties)&&(identical(other.priceRange, priceRange) || other.priceRange == priceRange)&&(identical(other.ratingRange, ratingRange) || other.ratingRange == ratingRange)&&(identical(other.freeOnly, freeOnly) || other.freeOnly == freeOnly)&&(identical(other.featuredOnly, featuredOnly) || other.featuredOnly == featuredOnly)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_subjects),const DeepCollectionEquality().hash(_grades),const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_difficulties),priceRange,ratingRange,freeOnly,featuredOnly,searchQuery,sortBy,language);

@override
String toString() {
  return 'FilterOptions(subjects: $subjects, grades: $grades, types: $types, difficulties: $difficulties, priceRange: $priceRange, ratingRange: $ratingRange, freeOnly: $freeOnly, featuredOnly: $featuredOnly, searchQuery: $searchQuery, sortBy: $sortBy, language: $language)';
}


}

/// @nodoc
abstract mixin class _$FilterOptionsCopyWith<$Res> implements $FilterOptionsCopyWith<$Res> {
  factory _$FilterOptionsCopyWith(_FilterOptions value, $Res Function(_FilterOptions) _then) = __$FilterOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<String> subjects, List<String> grades, List<MaterialType> types, List<MaterialDifficulty> difficulties, PriceRange priceRange, RatingRange ratingRange, bool freeOnly, bool featuredOnly, String searchQuery, SortOption sortBy, String language
});


@override $PriceRangeCopyWith<$Res> get priceRange;@override $RatingRangeCopyWith<$Res> get ratingRange;

}
/// @nodoc
class __$FilterOptionsCopyWithImpl<$Res>
    implements _$FilterOptionsCopyWith<$Res> {
  __$FilterOptionsCopyWithImpl(this._self, this._then);

  final _FilterOptions _self;
  final $Res Function(_FilterOptions) _then;

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subjects = null,Object? grades = null,Object? types = null,Object? difficulties = null,Object? priceRange = null,Object? ratingRange = null,Object? freeOnly = null,Object? featuredOnly = null,Object? searchQuery = null,Object? sortBy = null,Object? language = null,}) {
  return _then(_FilterOptions(
subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>,grades: null == grades ? _self._grades : grades // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<MaterialType>,difficulties: null == difficulties ? _self._difficulties : difficulties // ignore: cast_nullable_to_non_nullable
as List<MaterialDifficulty>,priceRange: null == priceRange ? _self.priceRange : priceRange // ignore: cast_nullable_to_non_nullable
as PriceRange,ratingRange: null == ratingRange ? _self.ratingRange : ratingRange // ignore: cast_nullable_to_non_nullable
as RatingRange,freeOnly: null == freeOnly ? _self.freeOnly : freeOnly // ignore: cast_nullable_to_non_nullable
as bool,featuredOnly: null == featuredOnly ? _self.featuredOnly : featuredOnly // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortOption,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceRange {
  
  return $PriceRangeCopyWith<$Res>(_self.priceRange, (value) {
    return _then(_self.copyWith(priceRange: value));
  });
}/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingRangeCopyWith<$Res> get ratingRange {
  
  return $RatingRangeCopyWith<$Res>(_self.ratingRange, (value) {
    return _then(_self.copyWith(ratingRange: value));
  });
}
}

/// @nodoc
mixin _$PriceRange {

 double get min; double get max;
/// Create a copy of PriceRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<PriceRange> get copyWith => _$PriceRangeCopyWithImpl<PriceRange>(this as PriceRange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'PriceRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $PriceRangeCopyWith<$Res>  {
  factory $PriceRangeCopyWith(PriceRange value, $Res Function(PriceRange) _then) = _$PriceRangeCopyWithImpl;
@useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class _$PriceRangeCopyWithImpl<$Res>
    implements $PriceRangeCopyWith<$Res> {
  _$PriceRangeCopyWithImpl(this._self, this._then);

  final PriceRange _self;
  final $Res Function(PriceRange) _then;

/// Create a copy of PriceRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceRange].
extension PriceRangePatterns on PriceRange {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceRange() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceRange value)  $default,){
final _that = this;
switch (_that) {
case _PriceRange():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceRange value)?  $default,){
final _that = this;
switch (_that) {
case _PriceRange() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double min,  double max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double min,  double max)  $default,) {final _that = this;
switch (_that) {
case _PriceRange():
return $default(_that.min,_that.max);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double min,  double max)?  $default,) {final _that = this;
switch (_that) {
case _PriceRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc


class _PriceRange implements PriceRange {
  const _PriceRange({this.min = 0.0, this.max = 1000.0});
  

@override@JsonKey() final  double min;
@override@JsonKey() final  double max;

/// Create a copy of PriceRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceRangeCopyWith<_PriceRange> get copyWith => __$PriceRangeCopyWithImpl<_PriceRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'PriceRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$PriceRangeCopyWith<$Res> implements $PriceRangeCopyWith<$Res> {
  factory _$PriceRangeCopyWith(_PriceRange value, $Res Function(_PriceRange) _then) = __$PriceRangeCopyWithImpl;
@override @useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class __$PriceRangeCopyWithImpl<$Res>
    implements _$PriceRangeCopyWith<$Res> {
  __$PriceRangeCopyWithImpl(this._self, this._then);

  final _PriceRange _self;
  final $Res Function(_PriceRange) _then;

/// Create a copy of PriceRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_PriceRange(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$RatingRange {

 double get min; double get max;
/// Create a copy of RatingRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingRangeCopyWith<RatingRange> get copyWith => _$RatingRangeCopyWithImpl<RatingRange>(this as RatingRange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatingRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'RatingRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $RatingRangeCopyWith<$Res>  {
  factory $RatingRangeCopyWith(RatingRange value, $Res Function(RatingRange) _then) = _$RatingRangeCopyWithImpl;
@useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class _$RatingRangeCopyWithImpl<$Res>
    implements $RatingRangeCopyWith<$Res> {
  _$RatingRangeCopyWithImpl(this._self, this._then);

  final RatingRange _self;
  final $Res Function(RatingRange) _then;

/// Create a copy of RatingRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RatingRange].
extension RatingRangePatterns on RatingRange {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatingRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatingRange() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatingRange value)  $default,){
final _that = this;
switch (_that) {
case _RatingRange():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatingRange value)?  $default,){
final _that = this;
switch (_that) {
case _RatingRange() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double min,  double max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatingRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double min,  double max)  $default,) {final _that = this;
switch (_that) {
case _RatingRange():
return $default(_that.min,_that.max);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double min,  double max)?  $default,) {final _that = this;
switch (_that) {
case _RatingRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc


class _RatingRange implements RatingRange {
  const _RatingRange({this.min = 0.0, this.max = 5.0});
  

@override@JsonKey() final  double min;
@override@JsonKey() final  double max;

/// Create a copy of RatingRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingRangeCopyWith<_RatingRange> get copyWith => __$RatingRangeCopyWithImpl<_RatingRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatingRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'RatingRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$RatingRangeCopyWith<$Res> implements $RatingRangeCopyWith<$Res> {
  factory _$RatingRangeCopyWith(_RatingRange value, $Res Function(_RatingRange) _then) = __$RatingRangeCopyWithImpl;
@override @useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class __$RatingRangeCopyWithImpl<$Res>
    implements _$RatingRangeCopyWith<$Res> {
  __$RatingRangeCopyWithImpl(this._self, this._then);

  final _RatingRange _self;
  final $Res Function(_RatingRange) _then;

/// Create a copy of RatingRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_RatingRange(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
