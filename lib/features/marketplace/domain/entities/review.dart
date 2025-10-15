import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String materialId,
    required String userId,
    required String userName,
    required String userAvatar,
    required int rating,
    required String comment,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isVerified,
    required List<String> helpfulVotes,
    required bool isEdited,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  
}
