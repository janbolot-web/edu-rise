import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/purchase_service.dart';

class PurchaseCourseDialog extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final double price;

  const PurchaseCourseDialog({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.price,
  });

  @override
  ConsumerState<PurchaseCourseDialog> createState() => _PurchaseCourseDialogState();
}

class _PurchaseCourseDialogState extends ConsumerState<PurchaseCourseDialog> {
  bool _isLoading = false;

  Future<void> _purchaseCourse() async {
    setState(() => _isLoading = true);

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final success = await purchaseService.purchaseCourse(widget.courseId);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при покупке курса')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Покупка курса'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Курс: ${widget.courseName}'),
          const SizedBox(height: 8),
          Text('Стоимость: ${widget.price} ₽'),
          const SizedBox(height: 16),
          const Text(
            'После оплаты вы получите полный доступ к материалам курса.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _purchaseCourse,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Купить'),
        ),
      ],
    );
  }
}
