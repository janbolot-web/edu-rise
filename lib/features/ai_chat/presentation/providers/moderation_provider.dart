import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/features/ai_chat/data/services/moderation_service.dart';

/// Provider для сервиса модерации
final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService();
});
