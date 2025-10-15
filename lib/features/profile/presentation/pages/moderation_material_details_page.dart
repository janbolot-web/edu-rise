import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';

class ModerationMaterialDetailsPage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> material;
  const ModerationMaterialDetailsPage({super.key, required this.id, required this.material});

  @override
  Widget build(BuildContext context) {
    final title = (material['title'] ?? 'Без названия').toString();
    final author = (material['authorName'] ?? 'Неизвестно').toString();
    final avatar = (material['authorAvatar'] ?? '').toString();
    final thumbnail = (material['thumbnailUrl'] ?? '').toString();
    final description = (material['description'] ?? '').toString();
    final preview = (material['previewText'] ?? '').toString();
    final type = (material['type'] ?? '').toString();
    final subject = (material['subject'] ?? '').toString();
    final grade = (material['grade'] ?? '').toString();
    final price = (material['price'] ?? 0).toDouble();
    final language = (material['language'] ?? '').toString();
    final difficulty = (material['difficulty'] ?? '').toString();
    final tags = List<String>.from(material['tags'] ?? const <String>[]);
    final objectives = List<String>.from(material['learningObjectives'] ?? const <String>[]);
    final fileUrls = List<String>.from(material['fileUrls'] ?? const <String>[]);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Проверка материала', style: GoogleFonts.montserrat(color: appPrimary, fontWeight: FontWeight.w700)),
      ),
      bottomNavigationBar: _ModerationActions(id: id),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SafeNetworkImage(
                    src: thumbnail,
                    fallbackAsset: 'assets/images/card-1.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: appPrimary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: Colors.white, child: ClipOval(child: SafeNetworkImage(src: avatar, fallbackAsset: 'assets/images/author.png', width: 28, height: 28, fit: BoxFit.cover))),
                        const SizedBox(width: 8),
                        Text(author, style: GoogleFonts.montserrat(color: appSecondary, fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        if (type.isNotEmpty) _chip(type),
                        if (subject.isNotEmpty) _chip(subject),
                        if (grade.isNotEmpty) _chip(grade),
                        if (difficulty.isNotEmpty) _chip(difficulty),
                        if (language.isNotEmpty) _chip(language),
                        _chip(price > 0 ? '${price.toStringAsFixed(0)} сом' : 'Бесплатно'),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (preview.isNotEmpty) _card('Краткое описание', Text(preview, style: GoogleFonts.montserrat(color: appPrimary))),
          if (description.isNotEmpty) _card('Описание', Text(description, style: GoogleFonts.montserrat(color: appPrimary, height: 1.4))),
          if (objectives.isNotEmpty)
            _card(
              'Цели обучения',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: objectives.map((e) => _bullet(e)).toList(),
              ),
            ),
          if (tags.isNotEmpty)
            _card(
              'Теги',
              Wrap(spacing: 8, runSpacing: 8, children: tags.map(_chip).toList()),
            ),
          _card(
            'Файлы',
            fileUrls.isEmpty
                ? Text('Нет прикреплённых файлов', style: GoogleFonts.montserrat(color: appSecondary))
                : Column(
                    children: fileUrls
                        .map((u) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.insert_drive_file, color: appPrimary),
                              title: Text(u, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(color: appPrimary)),
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: appPrimary)),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: appAccentStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, color: appAccentStart, fontWeight: FontWeight.w600)),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: appSecondary)),
          Expanded(child: Text(text, style: GoogleFonts.montserrat(color: appPrimary))),
        ],
      ),
    );
  }
}

class _ModerationActions extends StatelessWidget {
  final String id;
  const _ModerationActions({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _reject(context),
              icon: const Icon(Icons.close, color: Colors.red),
              label: Text('Отклонить', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approve(context),
              icon: const Icon(Icons.check),
              label: Text('Одобрить', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: appAccentEnd, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    await FirebaseFirestore.instance.collection('educational_materials').doc(id).update({
      'moderationStatus': 'approved',
      'isPublished': true,
      'moderatedAt': FieldValue.serverTimestamp(),
      'moderationComment': null,
    });
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Материал одобрен')));
    }
  }

  Future<void> _reject(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Причина отклонения'),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Опишите причину...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Отклонить')),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    await FirebaseFirestore.instance.collection('educational_materials').doc(id).update({
      'moderationStatus': 'rejected',
      'isPublished': false,
      'moderatedAt': FieldValue.serverTimestamp(),
      'moderationComment': reason,
    });
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Материал отклонён')));
    }
  }
}












