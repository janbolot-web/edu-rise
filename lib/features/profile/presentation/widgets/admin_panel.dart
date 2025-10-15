import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _idController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.5');
  // Gradient hex input controller
  final _gradientController = TextEditingController();

  List<Map<String, String>> lessons = [];

  @override
  void dispose() {
    _titleController.dispose();
    _idController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _addLessonField() {
    setState(() {
      lessons.add({'title': '', 'videoUrl': ''});
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.isNotEmpty
        ? _idController.text
        : DateTime.now().millisecondsSinceEpoch.toString();

  final rawGradient = _gradientController.text.trim();
  final gradientList = rawGradient.isEmpty
    ? []
    : rawGradient.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  final courseData = {
      'id': id,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'author': _authorController.text.trim(),
      'imageUrl': _imageController.text.trim(),
    'gradientColors': gradientList,
      'rating': double.tryParse(_ratingController.text) ?? 4.5,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'modules': [
        {
          'id': 'module-1',
          'title': 'Module 1',
          'description': '',
          'duration': lessons.length * 10,
          'lessons': lessons
              .asMap()
              .entries
              .map((e) => {
                    'id': 'lesson-${e.key + 1}',
                    'title': e.value['title'] ?? '',
                    'duration': 10,
                    'isPreview': true,
                    'videoUrl': e.value['videoUrl'] ?? '',
                    'description': '',
                  })
              .toList(),
        }
      ],
    };

    try {
      // Save to Firestore 'courses' collection
      await FirebaseFirestore.instance.collection('courses').doc(id).set(courseData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Курс успешно добавлен в Firestore')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Admin — Add Course', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              // Promote user by phone
              _PromoteByPhoneWidget(),
              const Divider(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Course ID (optional)'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gradientController,
                decoration: const InputDecoration(
                  labelText: 'Gradient colors (comma separated hex, e.g. #FFAC71,#FF8450)'
                ),
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(labelText: 'Rating'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Text('Lessons', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...lessons.asMap().entries.map((entry) {
                final idx = entry.key;
                return Column(
                  children: [
                    TextFormField(
                      initialValue: entry.value['title'],
                      decoration: InputDecoration(labelText: 'Lesson ${idx + 1} Title'),
                      onChanged: (v) => lessons[idx]['title'] = v,
                    ),
                    TextFormField(
                      initialValue: entry.value['videoUrl'],
                      decoration: InputDecoration(labelText: 'Lesson ${idx + 1} Video URL'),
                      onChanged: (v) => lessons[idx]['videoUrl'] = v,
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addLessonField,
                icon: const Icon(Icons.add),
                label: const Text('Add lesson'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save to Realtime Database'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoteByPhoneWidget extends StatefulWidget {
  @override
  State<_PromoteByPhoneWidget> createState() => _PromoteByPhoneWidgetState();
}

class _PromoteByPhoneWidgetState extends State<_PromoteByPhoneWidget> {
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _promote() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final query = await usersRef.where('phoneNumber', isEqualTo: phone).limit(1).get();
      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пользователь не найден')));
        return;
      }
      final doc = query.docs.first;
      await doc.reference.set({'role': 'admin'}, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Роль обновлена: admin')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promote user to admin', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone (e.g. +996999137500)'),
            ),
          ),
          const SizedBox(width: 8),
          _loading
              ? const SizedBox(width: 36, height: 36, child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _promote, child: const Text('Promote')),
        ]),
        const SizedBox(height: 8),
      ],
    );
  }
}
