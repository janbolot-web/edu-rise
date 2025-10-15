// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'educational_material.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EducationalMaterial {

 String get id; String get title; String get description; String get authorId; String get authorName; String get authorAvatar; MaterialType get type; String get subject; String get grade; double get price; String get currency; String get thumbnailUrl; List<String> get fileUrls; int get downloads; double get rating; int get reviewCount; DateTime get createdAt; DateTime get updatedAt; bool get isPublished; List<String> get tags; String get language; int get fileSize; String get fileFormat; MaterialDifficulty get difficulty; int get estimatedTime;// в минутах
 String get previewText; List<String> get learningObjectives; bool get isFree; bool get isFeatured; int get viewCount; ModerationStatus get moderationStatus; String? get moderationComment; String? get moderatedBy; DateTime? get moderatedAt;
/// Create a copy of EducationalMaterial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EducationalMaterialCopyWith<EducationalMaterial> get copyWith => _$EducationalMaterialCopyWithImpl<EducationalMaterial>(this as EducationalMaterial, _$identity);

  /// Serializes this EducationalMaterial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EducationalMaterial&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other.fileUrls, fileUrls)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.language, language) || other.language == language)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileFormat, fileFormat) || other.fileFormat == fileFormat)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.previewText, previewText) || other.previewText == previewText)&&const DeepCollectionEquality().equals(other.learningObjectives, learningObjectives)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.moderationComment, moderationComment) || other.moderationComment == moderationComment)&&(identical(other.moderatedBy, moderatedBy) || other.moderatedBy == moderatedBy)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,authorId,authorName,authorAvatar,type,subject,grade,price,currency,thumbnailUrl,const DeepCollectionEquality().hash(fileUrls),downloads,rating,reviewCount,createdAt,updatedAt,isPublished,const DeepCollectionEquality().hash(tags),language,fileSize,fileFormat,difficulty,estimatedTime,previewText,const DeepCollectionEquality().hash(learningObjectives),isFree,isFeatured,viewCount,moderationStatus,moderationComment,moderatedBy,moderatedAt]);

@override
String toString() {
  return 'EducationalMaterial(id: $id, title: $title, description: $description, authorId: $authorId, authorName: $authorName, authorAvatar: $authorAvatar, type: $type, subject: $subject, grade: $grade, price: $price, currency: $currency, thumbnailUrl: $thumbnailUrl, fileUrls: $fileUrls, downloads: $downloads, rating: $rating, reviewCount: $reviewCount, createdAt: $createdAt, updatedAt: $updatedAt, isPublished: $isPublished, tags: $tags, language: $language, fileSize: $fileSize, fileFormat: $fileFormat, difficulty: $difficulty, estimatedTime: $estimatedTime, previewText: $previewText, learningObjectives: $learningObjectives, isFree: $isFree, isFeatured: $isFeatured, viewCount: $viewCount, moderationStatus: $moderationStatus, moderationComment: $moderationComment, moderatedBy: $moderatedBy, moderatedAt: $moderatedAt)';
}


}

/// @nodoc
abstract mixin class $EducationalMaterialCopyWith<$Res>  {
  factory $EducationalMaterialCopyWith(EducationalMaterial value, $Res Function(EducationalMaterial) _then) = _$EducationalMaterialCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String authorId, String authorName, String authorAvatar, MaterialType type, String subject, String grade, double price, String currency, String thumbnailUrl, List<String> fileUrls, int downloads, double rating, int reviewCount, DateTime createdAt, DateTime updatedAt, bool isPublished, List<String> tags, String language, int fileSize, String fileFormat, MaterialDifficulty difficulty, int estimatedTime, String previewText, List<String> learningObjectives, bool isFree, bool isFeatured, int viewCount, ModerationStatus moderationStatus, String? moderationComment, String? moderatedBy, DateTime? moderatedAt
});




}
/// @nodoc
class _$EducationalMaterialCopyWithImpl<$Res>
    implements $EducationalMaterialCopyWith<$Res> {
  _$EducationalMaterialCopyWithImpl(this._self, this._then);

  final EducationalMaterial _self;
  final $Res Function(EducationalMaterial) _then;

/// Create a copy of EducationalMaterial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? authorId = null,Object? authorName = null,Object? authorAvatar = null,Object? type = null,Object? subject = null,Object? grade = null,Object? price = null,Object? currency = null,Object? thumbnailUrl = null,Object? fileUrls = null,Object? downloads = null,Object? rating = null,Object? reviewCount = null,Object? createdAt = null,Object? updatedAt = null,Object? isPublished = null,Object? tags = null,Object? language = null,Object? fileSize = null,Object? fileFormat = null,Object? difficulty = null,Object? estimatedTime = null,Object? previewText = null,Object? learningObjectives = null,Object? isFree = null,Object? isFeatured = null,Object? viewCount = null,Object? moderationStatus = null,Object? moderationComment = freezed,Object? moderatedBy = freezed,Object? moderatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatar: null == authorAvatar ? _self.authorAvatar : authorAvatar // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaterialType,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,fileUrls: null == fileUrls ? _self.fileUrls : fileUrls // ignore: cast_nullable_to_non_nullable
as List<String>,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileFormat: null == fileFormat ? _self.fileFormat : fileFormat // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as MaterialDifficulty,estimatedTime: null == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int,previewText: null == previewText ? _self.previewText : previewText // ignore: cast_nullable_to_non_nullable
as String,learningObjectives: null == learningObjectives ? _self.learningObjectives : learningObjectives // ignore: cast_nullable_to_non_nullable
as List<String>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus,moderationComment: freezed == moderationComment ? _self.moderationComment : moderationComment // ignore: cast_nullable_to_non_nullable
as String?,moderatedBy: freezed == moderatedBy ? _self.moderatedBy : moderatedBy // ignore: cast_nullable_to_non_nullable
as String?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EducationalMaterial].
extension EducationalMaterialPatterns on EducationalMaterial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EducationalMaterial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EducationalMaterial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EducationalMaterial value)  $default,){
final _that = this;
switch (_that) {
case _EducationalMaterial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EducationalMaterial value)?  $default,){
final _that = this;
switch (_that) {
case _EducationalMaterial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String authorId,  String authorName,  String authorAvatar,  MaterialType type,  String subject,  String grade,  double price,  String currency,  String thumbnailUrl,  List<String> fileUrls,  int downloads,  double rating,  int reviewCount,  DateTime createdAt,  DateTime updatedAt,  bool isPublished,  List<String> tags,  String language,  int fileSize,  String fileFormat,  MaterialDifficulty difficulty,  int estimatedTime,  String previewText,  List<String> learningObjectives,  bool isFree,  bool isFeatured,  int viewCount,  ModerationStatus moderationStatus,  String? moderationComment,  String? moderatedBy,  DateTime? moderatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EducationalMaterial() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.authorId,_that.authorName,_that.authorAvatar,_that.type,_that.subject,_that.grade,_that.price,_that.currency,_that.thumbnailUrl,_that.fileUrls,_that.downloads,_that.rating,_that.reviewCount,_that.createdAt,_that.updatedAt,_that.isPublished,_that.tags,_that.language,_that.fileSize,_that.fileFormat,_that.difficulty,_that.estimatedTime,_that.previewText,_that.learningObjectives,_that.isFree,_that.isFeatured,_that.viewCount,_that.moderationStatus,_that.moderationComment,_that.moderatedBy,_that.moderatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String authorId,  String authorName,  String authorAvatar,  MaterialType type,  String subject,  String grade,  double price,  String currency,  String thumbnailUrl,  List<String> fileUrls,  int downloads,  double rating,  int reviewCount,  DateTime createdAt,  DateTime updatedAt,  bool isPublished,  List<String> tags,  String language,  int fileSize,  String fileFormat,  MaterialDifficulty difficulty,  int estimatedTime,  String previewText,  List<String> learningObjectives,  bool isFree,  bool isFeatured,  int viewCount,  ModerationStatus moderationStatus,  String? moderationComment,  String? moderatedBy,  DateTime? moderatedAt)  $default,) {final _that = this;
switch (_that) {
case _EducationalMaterial():
return $default(_that.id,_that.title,_that.description,_that.authorId,_that.authorName,_that.authorAvatar,_that.type,_that.subject,_that.grade,_that.price,_that.currency,_that.thumbnailUrl,_that.fileUrls,_that.downloads,_that.rating,_that.reviewCount,_that.createdAt,_that.updatedAt,_that.isPublished,_that.tags,_that.language,_that.fileSize,_that.fileFormat,_that.difficulty,_that.estimatedTime,_that.previewText,_that.learningObjectives,_that.isFree,_that.isFeatured,_that.viewCount,_that.moderationStatus,_that.moderationComment,_that.moderatedBy,_that.moderatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String authorId,  String authorName,  String authorAvatar,  MaterialType type,  String subject,  String grade,  double price,  String currency,  String thumbnailUrl,  List<String> fileUrls,  int downloads,  double rating,  int reviewCount,  DateTime createdAt,  DateTime updatedAt,  bool isPublished,  List<String> tags,  String language,  int fileSize,  String fileFormat,  MaterialDifficulty difficulty,  int estimatedTime,  String previewText,  List<String> learningObjectives,  bool isFree,  bool isFeatured,  int viewCount,  ModerationStatus moderationStatus,  String? moderationComment,  String? moderatedBy,  DateTime? moderatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EducationalMaterial() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.authorId,_that.authorName,_that.authorAvatar,_that.type,_that.subject,_that.grade,_that.price,_that.currency,_that.thumbnailUrl,_that.fileUrls,_that.downloads,_that.rating,_that.reviewCount,_that.createdAt,_that.updatedAt,_that.isPublished,_that.tags,_that.language,_that.fileSize,_that.fileFormat,_that.difficulty,_that.estimatedTime,_that.previewText,_that.learningObjectives,_that.isFree,_that.isFeatured,_that.viewCount,_that.moderationStatus,_that.moderationComment,_that.moderatedBy,_that.moderatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EducationalMaterial implements EducationalMaterial {
  const _EducationalMaterial({required this.id, required this.title, required this.description, required this.authorId, required this.authorName, required this.authorAvatar, required this.type, required this.subject, required this.grade, required this.price, required this.currency, required this.thumbnailUrl, required final  List<String> fileUrls, required this.downloads, required this.rating, required this.reviewCount, required this.createdAt, required this.updatedAt, required this.isPublished, required final  List<String> tags, required this.language, required this.fileSize, required this.fileFormat, required this.difficulty, required this.estimatedTime, required this.previewText, required final  List<String> learningObjectives, required this.isFree, required this.isFeatured, required this.viewCount, this.moderationStatus = ModerationStatus.pending, this.moderationComment, this.moderatedBy, this.moderatedAt}): _fileUrls = fileUrls,_tags = tags,_learningObjectives = learningObjectives;
  factory _EducationalMaterial.fromJson(Map<String, dynamic> json) => _$EducationalMaterialFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String authorId;
@override final  String authorName;
@override final  String authorAvatar;
@override final  MaterialType type;
@override final  String subject;
@override final  String grade;
@override final  double price;
@override final  String currency;
@override final  String thumbnailUrl;
 final  List<String> _fileUrls;
@override List<String> get fileUrls {
  if (_fileUrls is EqualUnmodifiableListView) return _fileUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileUrls);
}

@override final  int downloads;
@override final  double rating;
@override final  int reviewCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  bool isPublished;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String language;
@override final  int fileSize;
@override final  String fileFormat;
@override final  MaterialDifficulty difficulty;
@override final  int estimatedTime;
// в минутах
@override final  String previewText;
 final  List<String> _learningObjectives;
@override List<String> get learningObjectives {
  if (_learningObjectives is EqualUnmodifiableListView) return _learningObjectives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_learningObjectives);
}

@override final  bool isFree;
@override final  bool isFeatured;
@override final  int viewCount;
@override@JsonKey() final  ModerationStatus moderationStatus;
@override final  String? moderationComment;
@override final  String? moderatedBy;
@override final  DateTime? moderatedAt;

/// Create a copy of EducationalMaterial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EducationalMaterialCopyWith<_EducationalMaterial> get copyWith => __$EducationalMaterialCopyWithImpl<_EducationalMaterial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EducationalMaterialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EducationalMaterial&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other._fileUrls, _fileUrls)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.language, language) || other.language == language)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileFormat, fileFormat) || other.fileFormat == fileFormat)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.previewText, previewText) || other.previewText == previewText)&&const DeepCollectionEquality().equals(other._learningObjectives, _learningObjectives)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.moderationComment, moderationComment) || other.moderationComment == moderationComment)&&(identical(other.moderatedBy, moderatedBy) || other.moderatedBy == moderatedBy)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,authorId,authorName,authorAvatar,type,subject,grade,price,currency,thumbnailUrl,const DeepCollectionEquality().hash(_fileUrls),downloads,rating,reviewCount,createdAt,updatedAt,isPublished,const DeepCollectionEquality().hash(_tags),language,fileSize,fileFormat,difficulty,estimatedTime,previewText,const DeepCollectionEquality().hash(_learningObjectives),isFree,isFeatured,viewCount,moderationStatus,moderationComment,moderatedBy,moderatedAt]);

@override
String toString() {
  return 'EducationalMaterial(id: $id, title: $title, description: $description, authorId: $authorId, authorName: $authorName, authorAvatar: $authorAvatar, type: $type, subject: $subject, grade: $grade, price: $price, currency: $currency, thumbnailUrl: $thumbnailUrl, fileUrls: $fileUrls, downloads: $downloads, rating: $rating, reviewCount: $reviewCount, createdAt: $createdAt, updatedAt: $updatedAt, isPublished: $isPublished, tags: $tags, language: $language, fileSize: $fileSize, fileFormat: $fileFormat, difficulty: $difficulty, estimatedTime: $estimatedTime, previewText: $previewText, learningObjectives: $learningObjectives, isFree: $isFree, isFeatured: $isFeatured, viewCount: $viewCount, moderationStatus: $moderationStatus, moderationComment: $moderationComment, moderatedBy: $moderatedBy, moderatedAt: $moderatedAt)';
}


}

/// @nodoc
abstract mixin class _$EducationalMaterialCopyWith<$Res> implements $EducationalMaterialCopyWith<$Res> {
  factory _$EducationalMaterialCopyWith(_EducationalMaterial value, $Res Function(_EducationalMaterial) _then) = __$EducationalMaterialCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String authorId, String authorName, String authorAvatar, MaterialType type, String subject, String grade, double price, String currency, String thumbnailUrl, List<String> fileUrls, int downloads, double rating, int reviewCount, DateTime createdAt, DateTime updatedAt, bool isPublished, List<String> tags, String language, int fileSize, String fileFormat, MaterialDifficulty difficulty, int estimatedTime, String previewText, List<String> learningObjectives, bool isFree, bool isFeatured, int viewCount, ModerationStatus moderationStatus, String? moderationComment, String? moderatedBy, DateTime? moderatedAt
});




}
/// @nodoc
class __$EducationalMaterialCopyWithImpl<$Res>
    implements _$EducationalMaterialCopyWith<$Res> {
  __$EducationalMaterialCopyWithImpl(this._self, this._then);

  final _EducationalMaterial _self;
  final $Res Function(_EducationalMaterial) _then;

/// Create a copy of EducationalMaterial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? authorId = null,Object? authorName = null,Object? authorAvatar = null,Object? type = null,Object? subject = null,Object? grade = null,Object? price = null,Object? currency = null,Object? thumbnailUrl = null,Object? fileUrls = null,Object? downloads = null,Object? rating = null,Object? reviewCount = null,Object? createdAt = null,Object? updatedAt = null,Object? isPublished = null,Object? tags = null,Object? language = null,Object? fileSize = null,Object? fileFormat = null,Object? difficulty = null,Object? estimatedTime = null,Object? previewText = null,Object? learningObjectives = null,Object? isFree = null,Object? isFeatured = null,Object? viewCount = null,Object? moderationStatus = null,Object? moderationComment = freezed,Object? moderatedBy = freezed,Object? moderatedAt = freezed,}) {
  return _then(_EducationalMaterial(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatar: null == authorAvatar ? _self.authorAvatar : authorAvatar // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaterialType,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,fileUrls: null == fileUrls ? _self._fileUrls : fileUrls // ignore: cast_nullable_to_non_nullable
as List<String>,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileFormat: null == fileFormat ? _self.fileFormat : fileFormat // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as MaterialDifficulty,estimatedTime: null == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int,previewText: null == previewText ? _self.previewText : previewText // ignore: cast_nullable_to_non_nullable
as String,learningObjectives: null == learningObjectives ? _self._learningObjectives : learningObjectives // ignore: cast_nullable_to_non_nullable
as List<String>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus,moderationComment: freezed == moderationComment ? _self.moderationComment : moderationComment // ignore: cast_nullable_to_non_nullable
as String?,moderatedBy: freezed == moderatedBy ? _self.moderatedBy : moderatedBy // ignore: cast_nullable_to_non_nullable
as String?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
