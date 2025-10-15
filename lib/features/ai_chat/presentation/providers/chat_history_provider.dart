import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/chat_history_service.dart';
import '../../data/models/chat_history_model.dart';

final chatHistoryServiceProvider = Provider((ref) => ChatHistoryService());

final chatHistoryStreamProvider = StreamProvider<List<ChatHistoryModel>>((ref) {
  final service = ref.watch(chatHistoryServiceProvider);
  return service.getChatsStream();
});
