import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_history_model.dart';
import 'moderation_service.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ModerationService _moderationService = ModerationService();

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  // Получить коллекцию чатов текущего пользователя
  CollectionReference get _chatsCollection =>
      _firestore.collection('users').doc(_userId).collection('chats');

  // Создать новый чат
  Future<String> createChat({String? title}) async {
    // Удаляем старые пустые чаты перед созданием нового
    await _deleteEmptyChats();
    
    final chat = ChatHistoryModel(
      id: '',
      userId: _userId,
      title: title ?? 'Новый чат',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    final docRef = await _chatsCollection.add(chat.toFirestore());
    return docRef.id;
  }

  // Удалить все пустые чаты
  Future<void> _deleteEmptyChats() async {
    final snapshot = await _chatsCollection.get();
    for (var doc in snapshot.docs) {
      final chat = ChatHistoryModel.fromFirestore(doc);
      if (chat.messages.isEmpty) {
        await doc.reference.delete();
      }
    }
  }

  // Сохранить сообщение в чат
  Future<void> saveMessage({
    required String chatId,
    required String text,
    String? filePath,
    bool isUser = false,
    bool isLoading = false,
    bool isError = false,
    List<String>? quickOptions,
    bool needsTextInput = false,
  }) async {
    final message = ChatMessageModel(
      text: text,
      filePath: filePath,
      isUser: isUser,
      isLoading: isLoading,
      isError: isError,
      quickOptions: quickOptions,
      needsTextInput: needsTextInput,
    );

    await _chatsCollection.doc(chatId).update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Сохранить весь список сообщений
  Future<void> saveMessages({
    required String chatId,
    required List<ChatMessageModel> messages,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'messages': messages.map((m) => m.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновить заголовок чата
  Future<void> updateChatTitle(String chatId, String title) async {
    await _chatsCollection.doc(chatId).update({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Получить чат по ID
  Future<ChatHistoryModel?> getChat(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return null;
    return ChatHistoryModel.fromFirestore(doc);
  }

  // Получить список всех чатов (только непустые)
  Stream<List<ChatHistoryModel>> getChatsStream() {
    return _chatsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatHistoryModel.fromFirestore(doc))
            .where((chat) => chat.messages.isNotEmpty) // Фильтруем пустые чаты
            .toList());
  }

  // Удалить чат
  Future<void> deleteChat(String chatId) async {
    await _chatsCollection.doc(chatId).delete();
  }

  // Очистить все чаты
  Future<void> clearAllChats() async {
    final snapshot = await _chatsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ===== МЕТОДЫ МОДЕРАЦИИ =====

  /// Модерирует сообщение перед сохранением
  Future<ModerationResult> moderateMessage(String text) async {
    return await _moderationService.moderateMessage(text);
  }

  /// Модерирует изображение
  Future<ModerationResult> moderateImage(String imagePath) async {
    return await _moderationService.moderateImage(imagePath);
  }

  /// Обновляет статус модерации чата
  Future<void> updateChatModerationStatus({
    required String chatId,
    required ModerationStatus status,
    String? comment,
    String? moderatedBy,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'moderationStatus': moderationStatusToString(status),
      'moderationComment': comment,
      'moderatedBy': moderatedBy,
      'moderatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Помечает чат как требующий проверки
  Future<void> flagChat({
    required String chatId,
    required String reason,
  }) async {
    await updateChatModerationStatus(
      chatId: chatId,
      status: ModerationStatus.flagged,
      comment: reason,
    );
  }

  /// Одобряет чат
  Future<void> approveChat({
    required String chatId,
    required String moderatorId,
  }) async {
    await updateChatModerationStatus(
      chatId: chatId,
      status: ModerationStatus.approved,
      moderatedBy: moderatorId,
    );
  }

  /// Отклоняет чат
  Future<void> rejectChat({
    required String chatId,
    required String moderatorId,
    required String reason,
  }) async {
    await updateChatModerationStatus(
      chatId: chatId,
      status: ModerationStatus.rejected,
      comment: reason,
      moderatedBy: moderatorId,
    );
  }

  /// Получает все чаты для модерации (только для модераторов)
  Stream<List<ChatHistoryModel>> getChatsForModeration({
    ModerationStatus? status,
  }) {
    Query query = _firestore
        .collectionGroup('chats')
        .orderBy('updatedAt', descending: true);

    if (status != null) {
      query = query.where(
        'moderationStatus',
        isEqualTo: moderationStatusToString(status),
      );
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ChatHistoryModel.fromFirestore(doc))
        .toList());
  }

  /// Получает количество чатов, требующих модерации
  Future<int> getPendingModerationCount() async {
    final snapshot = await _firestore
        .collectionGroup('chats')
        .where(
          'moderationStatus',
          isEqualTo: moderationStatusToString(
            ModerationStatus.pending,
          ),
        )
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }

  /// Получает количество помеченных чатов
  Future<int> getFlaggedChatsCount() async {
    final snapshot = await _firestore
        .collectionGroup('chats')
        .where(
          'moderationStatus',
          isEqualTo: moderationStatusToString(
            ModerationStatus.flagged,
          ),
        )
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }
}
