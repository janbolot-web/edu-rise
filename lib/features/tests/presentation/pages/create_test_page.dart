import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/test.dart';
import '../../domain/models/question.dart';
import '../../data/repositories/test_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final testRepositoryProvider = Provider((ref) => TestRepository());

class CreateTestPage extends ConsumerStatefulWidget {
  final Test? existingTest;

  const CreateTestPage({super.key, this.existingTest});

  @override
  ConsumerState<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends ConsumerState<CreateTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _subject = 'Математика';
  int _gradeLevel = 5;
  TestDifficulty _difficulty = TestDifficulty.medium;
  String? _coverImageUrl;
  List<Question> _questions = [];
  bool _isSaving = false;

  final List<String> _subjects = [
    'Математика',
    'Русский язык',
    'Английский язык',
    'Физика',
    'Химия',
    'Биология',
    'История',
    'География',
    'Литература',
    'Информатика',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingTest != null) {
      _titleController.text = widget.existingTest!.title;
      _descriptionController.text = widget.existingTest!.description;
      _durationController.text = widget.existingTest!.duration.toString();
      _subject = widget.existingTest!.subject;
      _gradeLevel = widget.existingTest!.gradeLevel;
      _difficulty = widget.existingTest!.difficulty;
      _coverImageUrl = widget.existingTest!.coverImage;
      _questions = List.from(widget.existingTest!.questions);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImageUrl = image.path;
      });
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _QuestionEditorDialog(
        onSave: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => _QuestionEditorDialog(
        question: _questions[index],
        onSave: (question) {
          setState(() {
            _questions[index] = question;
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveTest(TestStatus status) async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы один вопрос')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final test = Test(
        id: widget.existingTest?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        subject: _subject,
        gradeLevel: _gradeLevel,
        difficulty: _difficulty,
        duration: int.parse(_durationController.text),
        questions: _questions,
        teacherId: user.uid,
        teacherName: user.displayName ?? 'Unknown',
        status: status,
        createdAt: widget.existingTest?.createdAt ?? DateTime.now(),
        publishedAt: status == TestStatus.published ? DateTime.now() : null,
        coverImage: _coverImageUrl,
      );

      if (widget.existingTest == null) {
        await ref.read(testRepositoryProvider).createTest(test);
      } else {
        await ref.read(testRepositoryProvider).updateTest(test);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == TestStatus.published
                ? 'Тест опубликован'
                : 'Тест сохранён как черновик'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingTest == null ? 'Создать тест' : 'Редактировать тест',
          style: GoogleFonts.montserrat(
            color: appPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _saveTest(TestStatus.draft),
            child: Text(
              'Черновик',
              style: GoogleFonts.montserrat(color: appSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _saveTest(TestStatus.published),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Опубликовать',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 16),
            _buildCoverImage(),
            const SizedBox(height: 16),
            _buildQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Основная информация',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Название теста',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Введите название' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Описание',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 3,
            validator: (v) => v?.isEmpty ?? true ? 'Введите описание' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _subject,
            decoration: InputDecoration(
              labelText: 'Предмет',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _subject = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _gradeLevel,
                  decoration: InputDecoration(
                    labelText: 'Класс',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: List.generate(11, (i) => i + 1)
                      .map((i) => DropdownMenuItem(value: i, child: Text('$i класс')))
                      .toList(),
                  onChanged: (v) => setState(() => _gradeLevel = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<TestDifficulty>(
                  initialValue: _difficulty,
                  decoration: InputDecoration(
                    labelText: 'Сложность',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: TestDifficulty.values
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(_getDifficultyLabel(d)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _difficulty = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: 'Длительность (минуты)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Введите длительность' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Обложка',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_coverImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCoverImageWidget(),
            )
          else
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: appBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.image, size: 48, color: appSecondary)),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickCoverImage,
            icon: const Icon(Icons.upload),
            label: const Text('Выбрать изображение'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImageWidget() {
    final url = _coverImageUrl!;
    final uri = Uri.tryParse(url);
    final isHttp = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isHttp) {
      return Image.network(url, height: 150, fit: BoxFit.cover);
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, height: 150, fit: BoxFit.cover);
    }
    return const SizedBox(height: 150);
  }

  Widget _buildQuestions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопросы (${_questions.length})',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Добавить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appAccentEnd,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: appAccentEnd,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(_getQuestionTypeLabel(question.type)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: appSecondary),
                      onPressed: () => _editQuestion(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteQuestion(index),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDifficultyLabel(TestDifficulty d) {
    switch (d) {
      case TestDifficulty.easy:
        return 'Лёгкий';
      case TestDifficulty.medium:
        return 'Средний';
      case TestDifficulty.hard:
        return 'Сложный';
    }
  }

  String _getQuestionTypeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.multipleChoice:
        return 'Множественный выбор';
      case QuestionType.trueFalse:
        return 'Правда/Ложь';
      case QuestionType.shortAnswer:
        return 'Короткий ответ';
    }
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  final Question? question;
  final Function(Question) onSave;

  const _QuestionEditorDialog({this.question, required this.onSave});

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  QuestionType _type = QuestionType.multipleChoice;
  List<String> _options = ['', '', '', ''];
  String _correctAnswer = '';

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _textController.text = widget.question!.text;
      _explanationController.text = widget.question!.explanation ?? '';
      _pointsController.text = widget.question!.points.toString();
      _type = widget.question!.type;
      _options = List.from(widget.question!.options);
      _correctAnswer = widget.question!.correctAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.question == null ? 'Добавить вопрос' : 'Редактировать вопрос',
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Вопрос'),
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Введите вопрос' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Тип вопроса'),
                items: QuestionType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(_getTypeLabel(t))))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              if (_type == QuestionType.multipleChoice) ..._buildMultipleChoice(),
              if (_type == QuestionType.trueFalse) ..._buildTrueFalse(),
              if (_type == QuestionType.shortAnswer) ..._buildShortAnswer(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(labelText: 'Объяснение (опционально)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Баллы'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: appAccentEnd),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoice() {
    return [
      ...List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextFormField(
            initialValue: _options.length > i ? _options[i] : '',
            decoration: InputDecoration(labelText: 'Вариант ${i + 1}'),
            onChanged: (v) {
              if (_options.length <= i) {
                _options.add(v);
              } else {
                _options[i] = v;
              }
            },
          ),
        );
      }),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: _correctAnswer,
        decoration: const InputDecoration(labelText: 'Правильный ответ'),
        onChanged: (v) => _correctAnswer = v,
        validator: (v) => v?.isEmpty ?? true ? 'Укажите правильный ответ' : null,
      ),
    ];
  }

  List<Widget> _buildTrueFalse() {
    return [
      DropdownButtonFormField<String>(
        initialValue: _correctAnswer.isEmpty ? 'Правда' : _correctAnswer,
        decoration: const InputDecoration(labelText: 'Правильный ответ'),
        items: const [
          DropdownMenuItem(value: 'Правда', child: Text('Правда')),
          DropdownMenuItem(value: 'Ложь', child: Text('Ложь')),
        ],
        onChanged: (v) => setState(() => _correctAnswer = v!),
      ),
    ];
  }

  List<Widget> _buildShortAnswer() {
    return [
      TextFormField(
        initialValue: _correctAnswer,
        decoration: const InputDecoration(labelText: 'Правильный ответ'),
        onChanged: (v) => _correctAnswer = v,
        validator: (v) => v?.isEmpty ?? true ? 'Укажите правильный ответ' : null,
      ),
    ];
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final question = Question(
      id: widget.question?.id ?? const Uuid().v4(),
      text: _textController.text,
      type: _type,
      options: _type == QuestionType.multipleChoice ? _options : ['Правда', 'Ложь'],
      correctAnswer: _correctAnswer,
      explanation: _explanationController.text.isNotEmpty ? _explanationController.text : null,
      points: int.tryParse(_pointsController.text) ?? 1,
    );

    widget.onSave(question);
    Navigator.pop(context);
  }

  String _getTypeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.multipleChoice:
        return 'Множественный выбор';
      case QuestionType.trueFalse:
        return 'Правда/Ложь';
      case QuestionType.shortAnswer:
        return 'Короткий ответ';
    }
  }
}
