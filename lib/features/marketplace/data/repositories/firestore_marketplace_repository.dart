import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/educational_material.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/repositories/marketplace_repository.dart';

class FirestoreMarketplaceRepository implements MarketplaceRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreMarketplaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<String, List<EducationalMaterial>>> getMaterials({
    FilterOptions? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📊 [Firestore] Fetching materials with filters: $filters, page: $page');
      Query<Map<String, dynamic>> query = _firestore
          .collection('educational_materials')
          .where('isPublished', isEqualTo: true)
          .where('moderationStatus', isEqualTo: 'approved');

      // Simple query without complex indexing requirements
      query = query.orderBy('createdAt', descending: true);

      // Pagination
      query = query.limit(limit);
      if (page > 1) {
        final offset = (page - 1) * limit;
        // Note: Firestore doesn't support offset, you need to use cursor-based pagination
        // This is a simplified version
      }

      final snapshot = await query.get();
      print('📦 [Firestore] Got ${snapshot.docs.length} documents');
      
      final materials = snapshot.docs.map((doc) {
        final data = doc.data();
        return _materialFromFirestore(doc.id, data);
      }).toList();

      print('✅ [Firestore] Converted to ${materials.length} materials');
      return Right(materials);
    } catch (e) {
      print('❌ [Firestore] Error: $e');
      return Left('Failed to fetch materials: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, EducationalMaterial>> getMaterialById(String id) async {
    try {
      final doc = await _firestore
          .collection('educational_materials')
          .doc(id)
          .get();

      if (!doc.exists) {
        return const Left('Material not found');
      }

      final material = _materialFromFirestore(doc.id, doc.data()!);
      return Right(material);
    } catch (e) {
      return Left('Failed to fetch material: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getFeaturedMaterials() async {
    try {
      print('📊 [Firestore] Fetching featured materials');
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('isFeatured', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .where('moderationStatus', isEqualTo: 'approved')
          .limit(10)
          .get();

      final materials = snapshot.docs.map((doc) {
        final data = doc.data();
        return _materialFromFirestore(doc.id, data);
      }).toList();

      return Right(materials);
    } catch (e) {
      return Left('Failed to fetch featured materials: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getRecommendedMaterials(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('isPublished', isEqualTo: true)
          .where('moderationStatus', isEqualTo: 'approved')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      final materials = snapshot.docs.map((doc) {
        final data = doc.data();
        return _materialFromFirestore(doc.id, data);
      }).toList();

      return Right(materials);
    } catch (e) {
      return Left('Failed to fetch recommended materials: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getMaterialsByAuthor(String authorId) async {
    try {
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .get();

      final materials = snapshot.docs.map((doc) {
        final data = doc.data();
        return _materialFromFirestore(doc.id, data);
      }).toList();

      return Right(materials);
    } catch (e) {
      return Left('Failed to fetch author materials: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Review>>> getMaterialReviews(String materialId) async {
    try {
      final snapshot = await _firestore
          .collection('educational_materials')
          .doc(materialId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      final reviews = snapshot.docs.map((doc) {
        return _reviewFromFirestore(doc.id, doc.data());
      }).toList();

      return Right(reviews);
    } catch (e) {
      return Left('Failed to fetch reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Review>> addReview(Review review) async {
    try {
      final docRef = await _firestore
          .collection('educational_materials')
          .doc(review.materialId)
          .collection('reviews')
          .add({
        'userId': review.userId,
        'userName': review.userName,
        'userAvatar': review.userAvatar,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'helpfulVotes': [],
        'isEdited': false,
      });

      // Update material rating
      await _updateMaterialRating(review.materialId);

      final doc = await docRef.get();
      final addedReview = _reviewFromFirestore(doc.id, doc.data()!);
      
      return Right(addedReview);
    } catch (e) {
      return Left('Failed to add review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> purchaseMaterial(String materialId, String userId) async {
    try {
      await _firestore.collection('purchases').add({
        'materialId': materialId,
        'userId': userId,
        'purchaseDate': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      // Update downloads count
      await _firestore
          .collection('educational_materials')
          .doc(materialId)
          .update({
        'downloads': FieldValue.increment(1),
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to purchase material: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> downloadMaterial(String materialId, String userId) async {
    try {
      // Check if user has purchased the material
      final purchaseSnapshot = await _firestore
          .collection('purchases')
          .where('materialId', isEqualTo: materialId)
          .where('userId', isEqualTo: userId)
          .get();

      if (purchaseSnapshot.docs.isEmpty) {
        return const Left('Material not purchased');
      }

      // Update downloads count
      await _firestore
          .collection('educational_materials')
          .doc(materialId)
          .update({
        'downloads': FieldValue.increment(1),
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to download material: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getSubjects() async {
    try {
      // Get unique subjects from materials
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('isPublished', isEqualTo: true)
          .get();

      final subjects = <String>{};
      for (final doc in snapshot.docs) {
        final subject = doc.data()['subject'] as String?;
        if (subject != null) {
          subjects.add(subject);
        }
      }

      return Right(subjects.toList()..sort());
    } catch (e) {
      return Left('Failed to fetch subjects: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getGrades() async {
    try {
      // Get unique grades from materials
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('isPublished', isEqualTo: true)
          .get();

      final grades = <String>{};
      for (final doc in snapshot.docs) {
        final grade = doc.data()['grade'] as String?;
        if (grade != null) {
          grades.add(grade);
        }
      }

      return Right(grades.toList()..sort());
    } catch (e) {
      return Left('Failed to fetch grades: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> reportMaterial(String materialId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'materialId': materialId,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to report material: ${e.toString()}');
    }
  }

  // Helper methods
  EducationalMaterial _materialFromFirestore(String id, Map<String, dynamic> data) {
    return EducationalMaterial(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorAvatar: data['authorAvatar'] ?? '',
      type: _parseType(data['type']),
      subject: data['subject'] ?? '',
      grade: data['grade'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      downloads: data['downloads'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      language: data['language'] ?? 'en',
      fileSize: data['fileSize'] ?? 0,
      fileFormat: data['fileFormat'] ?? '',
      difficulty: _parseDifficulty(data['difficulty']),
      estimatedTime: data['estimatedTime'] ?? 0,
      previewText: data['previewText'] ?? '',
      learningObjectives: List<String>.from(data['learningObjectives'] ?? []),
      isFree: data['isFree'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      moderationStatus: _parseModerationStatus(data['moderationStatus']),
      moderationComment: data['moderationComment'],
      moderatedBy: data['moderatedBy'],
      moderatedAt: (data['moderatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Review _reviewFromFirestore(String id, Map<String, dynamic> data) {
    return Review(
      id: id,
      materialId: data['materialId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      helpfulVotes: List<String>.from(data['helpfulVotes'] ?? []),
      isEdited: data['isEdited'] ?? false,
    );
  }

  MaterialType _parseType(dynamic value) {
    if (value == null) return MaterialType.notes;
    final typeStr = value.toString();
    return MaterialType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => MaterialType.notes,
    );
  }

  MaterialDifficulty _parseDifficulty(dynamic value) {
    if (value == null) return MaterialDifficulty.beginner;
    final diffStr = value.toString();
    return MaterialDifficulty.values.firstWhere(
      (e) => e.name == diffStr,
      orElse: () => MaterialDifficulty.beginner,
    );
  }

  ModerationStatus _parseModerationStatus(dynamic value) {
    if (value == null) return ModerationStatus.pending;
    final statusStr = value.toString();
    return ModerationStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ModerationStatus.pending,
    );
  }

  Future<void> _updateMaterialRating(String materialId) async {
    final reviewsSnapshot = await _firestore
        .collection('educational_materials')
        .doc(materialId)
        .collection('reviews')
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    final ratings = reviewsSnapshot.docs
        .map((doc) => doc.data()['rating'] as int)
        .toList();

    final avgRating = ratings.reduce((a, b) => a + b) / ratings.length;

    await _firestore
        .collection('educational_materials')
        .doc(materialId)
        .update({
      'rating': avgRating,
      'reviewCount': ratings.length,
    });
  }

  // Moderation methods
  Future<Either<String, List<EducationalMaterial>>> getPendingMaterials() async {
    try {
      final snapshot = await _firestore
          .collection('educational_materials')
          .where('moderationStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final materials = snapshot.docs.map((doc) {
        return _materialFromFirestore(doc.id, doc.data());
      }).toList();

      return Right(materials);
    } catch (e) {
      return Left('Failed to fetch pending materials: ${e.toString()}');
    }
  }

  Future<Either<String, bool>> approveMaterial(String materialId, String adminId) async {
    try {
      await _firestore
          .collection('educational_materials')
          .doc(materialId)
          .update({
        'moderationStatus': 'approved',
        'isPublished': true,
        'moderatedBy': adminId,
        'moderatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to approve material: ${e.toString()}');
    }
  }

  Future<Either<String, bool>> rejectMaterial(
    String materialId,
    String adminId,
    String reason,
  ) async {
    try {
      await _firestore
          .collection('educational_materials')
          .doc(materialId)
          .update({
        'moderationStatus': 'rejected',
        'isPublished': false,
        'moderationComment': reason,
        'moderatedBy': adminId,
        'moderatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to reject material: ${e.toString()}');
    }
  }
}
