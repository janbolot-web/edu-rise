import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/review.dart';

class ReviewSection extends StatefulWidget {
  final String materialId;

  const ReviewSection({
    super.key,
    required this.materialId,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final List<Review> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Load reviews from provider
    // Mock data for now
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _reviews.addAll(_getMockReviews());
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Отзывы',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: appPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showAddReviewDialog();
                },
                child: Text(
                  'Написать отзыв',
                  style: GoogleFonts.montserrat(
                    color: appAccentEnd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: _reviews.map((review) => ReviewCard(review: review)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.reviews_outlined,
              size: 48,
              color: appSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нет отзывов',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: appPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Станьте первым, кто оставит отзыв об этом материале',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        materialId: widget.materialId,
        onReviewAdded: (review) {
          setState(() {
            _reviews.insert(0, review);
          });
        },
      ),
    );
  }

  List<Review> _getMockReviews() {
    return [
      Review(
        id: '1',
        materialId: widget.materialId,
        userId: 'user1',
        userName: 'Мария Иванова',
        userAvatar: 'https://example.com/avatar1.jpg',
        rating: 5,
        comment: 'Отличная презентация! Очень понятно объяснено, дети легко усвоили материал.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
        helpfulVotes: ['user2', 'user3'],
        isEdited: false,
      ),
      Review(
        id: '2',
        materialId: widget.materialId,
        userId: 'user2',
        userName: 'Алексей Петров',
        userAvatar: 'https://example.com/avatar2.jpg',
        rating: 4,
        comment: 'Хороший материал, но хотелось бы больше практических примеров.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: false,
        helpfulVotes: ['user1'],
        isEdited: false,
      ),
    ];
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.userAvatar),
                onBackgroundImageError: (_, __) {},
                child: Icon(
                  Icons.person,
                  color: appSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: appPrimary,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: appAccentEnd,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: appSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Comment
          Text(
            review.comment,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Toggle helpful vote
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: appSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Полезно (${review.helpfulVotes.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: appSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (review.isEdited)
                Text(
                  'Изменено',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: appSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

class AddReviewDialog extends StatefulWidget {
  final String materialId;
  final Function(Review) onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.materialId,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Оставить отзыв',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: appPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rating
          Text(
            'Оценка',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 32,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          
          // Comment
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Поделитесь своим мнением о материале...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appAccentEnd),
              ),
            ),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appPrimary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Отмена',
            style: GoogleFonts.montserrat(
              color: appSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: appAccentEnd,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Отправить',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _submitReview() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пожалуйста, напишите отзыв',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
      return;
    }

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      materialId: widget.materialId,
      userId: 'current_user', // TODO: Get from auth
      userName: 'Текущий пользователь', // TODO: Get from auth
      userAvatar: 'https://example.com/avatar.jpg', // TODO: Get from auth
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: false,
      helpfulVotes: [],
      isEdited: false,
    );

    widget.onReviewAdded(review);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Отзыв добавлен',
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
  }
}
