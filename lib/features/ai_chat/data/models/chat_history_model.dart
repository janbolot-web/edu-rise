import 'package:cloud_firestore/cloud_firestore.dart';

enum ModerationStatus {
  pending,
  approved,
  rejected,
  flagged,
}

/// Преобразует ModerationStatus в строку для Firestore
String moderationStatusToString(ModerationStatus status) {
  switch (status) {
    case ModerationStatus.pending:
      return 'pending';
    case ModerationStatus.approved:
      return 'approved';
    case ModerationStatus.rejected:
      return 'rejected';
    case ModerationStatus.flagged:
      return 'flagged';
  }
}

/// Преобразует строку из Firestore в ModerationStatus
ModerationStatus moderationStatusFromString(dynamic value) {
  if (value == null) return ModerationStatus.approved;
  if (value is String) {
    switch (value) {
      case 'pending':
        return ModerationStatus.pending;
      case 'approved':
        return ModerationStatus.approved;
      case 'rejected':
        return ModerationStatus.rejected;
      case 'flagged':
        return ModerationStatus.flagged;
      default:
        return ModerationStatus.approved;
    }
  }
  return ModerationStatus.approved;
}

class ChatHistoryModel {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;
  final ModerationStatus moderationStatus;
  final String? moderationComment;
  final String? moderatedBy;
  final DateTime? moderatedAt;

  ChatHistoryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.moderationStatus = ModerationStatus.approved,
    this.moderationComment,
    this.moderatedBy,
    this.moderatedAt,
  });

  factory ChatHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Новый чат',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messages: (data['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessageModel.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      moderationStatus: moderationStatusFromString(data['moderationStatus']),
      moderationComment: data['moderationComment'],
      moderatedBy: data['moderatedBy'],
      moderatedAt: (data['moderatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messages': messages.map((m) => m.toMap()).toList(),
      'moderationStatus': moderationStatusToString(moderationStatus),
      'moderationComment': moderationComment,
      'moderatedBy': moderatedBy,
      'moderatedAt': moderatedAt != null ? Timestamp.fromDate(moderatedAt!) : null,
    };
  }

  ChatHistoryModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessageModel>? messages,
    ModerationStatus? moderationStatus,
    String? moderationComment,
    String? moderatedBy,
    DateTime? moderatedAt,
  }) {
    return ChatHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationComment: moderationComment ?? this.moderationComment,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderatedAt: moderatedAt ?? this.moderatedAt,
    );
  }
}

class ChatMessageModel {
  final String text;
  final String? filePath;
  final bool isUser;
  final bool isLoading;
  final bool isError;
  final List<String>? quickOptions;
  final bool needsTextInput;
  final DateTime timestamp;
  final bool isFlagged;
  final String? flagReason;
  final List<String>? detectedIssues;

  ChatMessageModel({
    required this.text,
    this.filePath,
    this.isUser = false,
    this.isLoading = false,
    this.isError = false,
    this.quickOptions,
    this.needsTextInput = false,
    DateTime? timestamp,
    this.isFlagged = false,
    this.flagReason,
    this.detectedIssues,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      text: map['text'] ?? '',
      filePath: map['filePath'],
      isUser: map['isUser'] ?? false,
      isLoading: map['isLoading'] ?? false,
      isError: map['isError'] ?? false,
      quickOptions: (map['quickOptions'] as List<dynamic>?)?.cast<String>(),
      needsTextInput: map['needsTextInput'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFlagged: map['isFlagged'] ?? false,
      flagReason: map['flagReason'],
      detectedIssues: (map['detectedIssues'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'filePath': filePath,
      'isUser': isUser,
      'isLoading': isLoading,
      'isError': isError,
      'quickOptions': quickOptions,
      'needsTextInput': needsTextInput,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFlagged': isFlagged,
      'flagReason': flagReason,
      'detectedIssues': detectedIssues,
    };
  }
}
