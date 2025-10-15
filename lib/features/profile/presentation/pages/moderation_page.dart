import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'moderation_material_details_page.dart';

class ModerationPage extends StatelessWidget {
  const ModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: appBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: appPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Модерация материалов',
            style: GoogleFonts.montserrat(
              color: appPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelColor: appPrimary,
            indicatorColor: appAccentEnd,
            tabs: const [
              Tab(text: 'Ожидают'),
              Tab(text: 'Одобрено'),
              Tab(text: 'Отклонено'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ModerationList(status: 'pending'),
            _ModerationList(status: 'approved'),
            _ModerationList(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

class _ModerationList extends StatelessWidget {
  final String status;
  const _ModerationList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('educational_materials')
          .where('moderationStatus', isEqualTo: status)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorBox(message: '${snapshot.error}');
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyBox(message: _emptyText(status));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final id = docs[i].id;
            final title = (data['title'] ?? 'Без названия').toString();
            final author = (data['authorName'] ?? 'Неизвестно').toString();
            final type = (data['type'] ?? '').toString();
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: appPrimary.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                title: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: appPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Автор: $author',
                      style: GoogleFonts.montserrat(fontSize: 12, color: appSecondary),
                    ),
                    if (type.isNotEmpty)
                      Text(
                        'Тип: $type',
                        style: GoogleFonts.montserrat(fontSize: 12, color: appSecondary),
                      ),
                    if (createdAt != null)
                      Text(
                        'Добавлено: ${createdAt.toLocal()}',
                        style: GoogleFonts.montserrat(fontSize: 12, color: appSecondary),
                      ),
                  ],
                ),
                trailing: _Actions(
                  id: id,
                  status: status,
                  material: data,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ModerationMaterialDetailsPage(id: id, material: data),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static String _emptyText(String s) {
    switch (s) {
      case 'pending':
        return 'Нет материалов, ожидающих модерации';
      case 'approved':
        return 'Пока нет одобренных материалов';
      case 'rejected':
        return 'Пока нет отклонённых материалов';
      default:
        return 'Нет данных';
    }
  }

  // no-op helper removed
}

class _Actions extends StatelessWidget {
  final String id;
  final String status;
  final Map<String, dynamic> material;
  const _Actions({required this.id, required this.status, required this.material});

  @override
  Widget build(BuildContext context) {
    if (status == 'pending') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Одобрить',
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _approve(context),
          ),
          IconButton(
            tooltip: 'Отклонить',
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _reject(context),
          ),
        ],
      );
    }
    if (status == 'approved') {
      return IconButton(
        tooltip: 'Отклонить',
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () => _reject(context),
      );
    }
    return IconButton(
      tooltip: 'Одобрить',
      icon: const Icon(Icons.check_circle, color: Colors.green),
      onPressed: () => _approve(context),
    );
  }

  Future<void> _approve(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('educational_materials')
        .doc(id)
        .update({
          'moderationStatus': 'approved',
          'isPublished': true,
          'moderationComment': null,
          'moderatedAt': FieldValue.serverTimestamp(),
        });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Материал одобрен')),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    final reason = await _askReason(context);
    if (reason == null) return;
    await FirebaseFirestore.instance
        .collection('educational_materials')
        .doc(id)
        .update({
          'moderationStatus': 'rejected',
          'isPublished': false,
          'moderationComment': reason,
          'moderatedAt': FieldValue.serverTimestamp(),
        });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Материал отклонён')),
      );
    }
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Причина отклонения'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Укажите причину...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Отклонить'),
            ),
          ],
        );
      },
    ).then((v) => (v != null && v.isNotEmpty) ? v : null);
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;
  const _EmptyBox({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: GoogleFonts.montserrat(color: appSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.montserrat(color: appSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


