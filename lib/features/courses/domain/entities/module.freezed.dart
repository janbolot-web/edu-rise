// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourseModule {

 String get id; String get title; String get description; List<ModuleLesson> get lessons; int get duration;
/// Create a copy of CourseModule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseModuleCopyWith<CourseModule> get copyWith => _$CourseModuleCopyWithImpl<CourseModule>(this as CourseModule, _$identity);

  /// Serializes this CourseModule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourseModule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.lessons, lessons)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(lessons),duration);

@override
String toString() {
  return 'CourseModule(id: $id, title: $title, description: $description, lessons: $lessons, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CourseModuleCopyWith<$Res>  {
  factory $CourseModuleCopyWith(CourseModule value, $Res Function(CourseModule) _then) = _$CourseModuleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, List<ModuleLesson> lessons, int duration
});




}
/// @nodoc
class _$CourseModuleCopyWithImpl<$Res>
    implements $CourseModuleCopyWith<$Res> {
  _$CourseModuleCopyWithImpl(this._self, this._then);

  final CourseModule _self;
  final $Res Function(CourseModule) _then;

/// Create a copy of CourseModule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? lessons = null,Object? duration = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self.lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<ModuleLesson>,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CourseModule].
extension CourseModulePatterns on CourseModule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourseModule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourseModule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourseModule value)  $default,){
final _that = this;
switch (_that) {
case _CourseModule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourseModule value)?  $default,){
final _that = this;
switch (_that) {
case _CourseModule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<ModuleLesson> lessons,  int duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourseModule() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lessons,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<ModuleLesson> lessons,  int duration)  $default,) {final _that = this;
switch (_that) {
case _CourseModule():
return $default(_that.id,_that.title,_that.description,_that.lessons,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  List<ModuleLesson> lessons,  int duration)?  $default,) {final _that = this;
switch (_that) {
case _CourseModule() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lessons,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourseModule implements CourseModule {
  const _CourseModule({required this.id, required this.title, required this.description, required final  List<ModuleLesson> lessons, required this.duration}): _lessons = lessons;
  factory _CourseModule.fromJson(Map<String, dynamic> json) => _$CourseModuleFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
 final  List<ModuleLesson> _lessons;
@override List<ModuleLesson> get lessons {
  if (_lessons is EqualUnmodifiableListView) return _lessons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lessons);
}

@override final  int duration;

/// Create a copy of CourseModule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseModuleCopyWith<_CourseModule> get copyWith => __$CourseModuleCopyWithImpl<_CourseModule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseModuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourseModule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._lessons, _lessons)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(_lessons),duration);

@override
String toString() {
  return 'CourseModule(id: $id, title: $title, description: $description, lessons: $lessons, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$CourseModuleCopyWith<$Res> implements $CourseModuleCopyWith<$Res> {
  factory _$CourseModuleCopyWith(_CourseModule value, $Res Function(_CourseModule) _then) = __$CourseModuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, List<ModuleLesson> lessons, int duration
});




}
/// @nodoc
class __$CourseModuleCopyWithImpl<$Res>
    implements _$CourseModuleCopyWith<$Res> {
  __$CourseModuleCopyWithImpl(this._self, this._then);

  final _CourseModule _self;
  final $Res Function(_CourseModule) _then;

/// Create a copy of CourseModule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? lessons = null,Object? duration = null,}) {
  return _then(_CourseModule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self._lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<ModuleLesson>,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModuleLesson {

 String get id; String get title; int get duration;// в минутах
 bool get isPreview; String get videoUrl; String get description;
/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleLessonCopyWith<ModuleLesson> get copyWith => _$ModuleLessonCopyWithImpl<ModuleLesson>(this as ModuleLesson, _$identity);

  /// Serializes this ModuleLesson to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isPreview, isPreview) || other.isPreview == isPreview)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,duration,isPreview,videoUrl,description);

@override
String toString() {
  return 'ModuleLesson(id: $id, title: $title, duration: $duration, isPreview: $isPreview, videoUrl: $videoUrl, description: $description)';
}


}

/// @nodoc
abstract mixin class $ModuleLessonCopyWith<$Res>  {
  factory $ModuleLessonCopyWith(ModuleLesson value, $Res Function(ModuleLesson) _then) = _$ModuleLessonCopyWithImpl;
@useResult
$Res call({
 String id, String title, int duration, bool isPreview, String videoUrl, String description
});




}
/// @nodoc
class _$ModuleLessonCopyWithImpl<$Res>
    implements $ModuleLessonCopyWith<$Res> {
  _$ModuleLessonCopyWithImpl(this._self, this._then);

  final ModuleLesson _self;
  final $Res Function(ModuleLesson) _then;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? duration = null,Object? isPreview = null,Object? videoUrl = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isPreview: null == isPreview ? _self.isPreview : isPreview // ignore: cast_nullable_to_non_nullable
as bool,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ModuleLesson].
extension ModuleLessonPatterns on ModuleLesson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModuleLesson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModuleLesson value)  $default,){
final _that = this;
switch (_that) {
case _ModuleLesson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModuleLesson value)?  $default,){
final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int duration,  bool isPreview,  String videoUrl,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
return $default(_that.id,_that.title,_that.duration,_that.isPreview,_that.videoUrl,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int duration,  bool isPreview,  String videoUrl,  String description)  $default,) {final _that = this;
switch (_that) {
case _ModuleLesson():
return $default(_that.id,_that.title,_that.duration,_that.isPreview,_that.videoUrl,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int duration,  bool isPreview,  String videoUrl,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
return $default(_that.id,_that.title,_that.duration,_that.isPreview,_that.videoUrl,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModuleLesson implements ModuleLesson {
  const _ModuleLesson({required this.id, required this.title, required this.duration, this.isPreview = false, this.videoUrl = '', this.description = ''});
  factory _ModuleLesson.fromJson(Map<String, dynamic> json) => _$ModuleLessonFromJson(json);

@override final  String id;
@override final  String title;
@override final  int duration;
// в минутах
@override@JsonKey() final  bool isPreview;
@override@JsonKey() final  String videoUrl;
@override@JsonKey() final  String description;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModuleLessonCopyWith<_ModuleLesson> get copyWith => __$ModuleLessonCopyWithImpl<_ModuleLesson>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModuleLessonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isPreview, isPreview) || other.isPreview == isPreview)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,duration,isPreview,videoUrl,description);

@override
String toString() {
  return 'ModuleLesson(id: $id, title: $title, duration: $duration, isPreview: $isPreview, videoUrl: $videoUrl, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ModuleLessonCopyWith<$Res> implements $ModuleLessonCopyWith<$Res> {
  factory _$ModuleLessonCopyWith(_ModuleLesson value, $Res Function(_ModuleLesson) _then) = __$ModuleLessonCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int duration, bool isPreview, String videoUrl, String description
});




}
/// @nodoc
class __$ModuleLessonCopyWithImpl<$Res>
    implements _$ModuleLessonCopyWith<$Res> {
  __$ModuleLessonCopyWithImpl(this._self, this._then);

  final _ModuleLesson _self;
  final $Res Function(_ModuleLesson) _then;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? duration = null,Object? isPreview = null,Object? videoUrl = null,Object? description = null,}) {
  return _then(_ModuleLesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isPreview: null == isPreview ? _self.isPreview : isPreview // ignore: cast_nullable_to_non_nullable
as bool,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
