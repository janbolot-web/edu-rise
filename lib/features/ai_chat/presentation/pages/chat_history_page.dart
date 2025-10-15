import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../providers/chat_history_provider.dart';
import '../viewmodels/ai_chat_viewmodel.dart';
import 'package:intl/intl.dart';

class ChatHistoryPage extends ConsumerWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryStreamProvider);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text(
          'История чатов',
          style: TextStyle(
            color: appPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: appPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await ref.read(aiChatViewModelProvider.notifier).createNewChat();
              if (context.mounted) Navigator.pop(context);
            },
            tooltip: 'Новый чат',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: appSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет истории чатов',
                    style: TextStyle(
                      color: appSecondary.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(aiChatViewModelProvider.notifier).createNewChat();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Создать чат'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccentEnd,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
              
              return Dismissible(
                key: Key(chat.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) async {
                  final service = ref.read(chatHistoryServiceProvider);
                  await service.deleteChat(chat.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Чат удален')),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: InkWell(
                    onTap: () async {
                      await ref.read(aiChatViewModelProvider.notifier).loadChat(chat.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [appAccentStart, appAccentEnd],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chat.title,
                                      style: const TextStyle(
                                        color: appPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(chat.updatedAt),
                                      style: TextStyle(
                                        color: appSecondary.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: appSecondary.withOpacity(0.5),
                              ),
                            ],
                          ),
                          if (chat.messages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              chat.messages.last.text,
                              style: TextStyle(
                                color: appSecondary.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }
}
