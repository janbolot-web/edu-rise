import 'package:flutter/material.dart' hide MaterialType;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';

class AddMaterialPage extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  // Form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _previewTextController = TextEditingController();
  
  MaterialType? _selectedType;
  String? _selectedSubject;
  String? _selectedGrade;
  MaterialDifficulty? _selectedDifficulty;
  bool _isFree = false;
  final List<String> _learningObjectives = [''];
  final List<String> _selectedTags = [];

  final List<String> _subjects = [
    'Математика',
    'Русский язык',
    'Английский язык',
    'Физика',
    'Химия',
    'Биология',
    'География',
    'История',
    'Литература',
    'Информатика',
  ];

  final List<String> _grades = [
    '1 класс',
    '2 класс',
    '3 класс',
    '4 класс',
    '5 класс',
    '6 класс',
    '7 класс',
    '8 класс',
    '9 класс',
    '10 класс',
    '11 класс',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _previewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Добавить материал',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: appPrimary,
          ),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: appAccentEnd,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccentEnd,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Опубликовать' : 'Далее',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_currentStep > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextButton(
                        onPressed: details.onStepCancel,
                        child: Text(
                          'Назад',
                          style: GoogleFonts.montserrat(
                            color: appSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Шаг 1: Основная информация
            Step(
              title: Text(
                'Основная информация',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              content: _buildBasicInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            
            // Шаг 2: Детали материала
            Step(
              title: Text(
                'Детали материала',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              content: _buildDetailsStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            
            // Шаг 3: Цена и публикация
            Step(
              title: Text(
                'Цена и публикация',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              content: _buildPricingStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Название материала *'),
        TextField(
          controller: _titleController,
          decoration: _inputDecoration('Например: "Урок математики для 5 класса"'),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        
        _buildLabel('Тип материала *'),
        _buildTypeSelector(),
        const SizedBox(height: 20),
        
        _buildLabel('Предмет *'),
        DropdownButtonFormField<String>(
          initialValue: _selectedSubject,
          decoration: _inputDecoration('Выберите предмет'),
          items: _subjects.map((subject) {
            return DropdownMenuItem(
              value: subject,
              child: Text(subject),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        _buildLabel('Класс *'),
        DropdownButtonFormField<String>(
          initialValue: _selectedGrade,
          decoration: _inputDecoration('Выберите класс'),
          items: _grades.map((grade) {
            return DropdownMenuItem(
              value: grade,
              child: Text(grade),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGrade = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Описание *'),
        TextField(
          controller: _descriptionController,
          decoration: _inputDecoration(
            'Подробно опишите ваш материал, что в нём содержится',
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        
        _buildLabel('Краткое описание для предпросмотра'),
        TextField(
          controller: _previewTextController,
          decoration: _inputDecoration(
            'Краткое описание (1-2 предложения)',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        
        _buildLabel('Уровень сложности *'),
        _buildDifficultySelector(),
        const SizedBox(height: 20),
        
        _buildLabel('Цели обучения'),
        _buildLearningObjectives(),
      ],
    );
  }

  Widget _buildPricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isFree,
              onChanged: (value) {
                setState(() {
                  _isFree = value ?? false;
                  if (_isFree) {
                    _priceController.text = '0';
                  }
                });
              },
            ),
            Text(
              'Бесплатный материал',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (!_isFree) ...[
          _buildLabel('Цена (в сомах) *'),
          TextField(
            controller: _priceController,
            decoration: _inputDecoration('Например: 100'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
        ],
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appAccentEnd.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appAccentEnd.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: appAccentEnd),
                  const SizedBox(width: 8),
                  Text(
                    'Важная информация',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• После публикации материал проходит модерацию\n'
                '• Вы получаете 70% от стоимости каждой покупки\n'
                '• Материал можно редактировать в любое время',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      _TypeOption(
        type: MaterialType.presentation,
        icon: Icons.slideshow,
        label: 'Презентация',
      ),
      _TypeOption(
        type: MaterialType.notes,
        icon: Icons.note,
        label: 'Конспект',
      ),
      _TypeOption(
        type: MaterialType.test,
        icon: Icons.quiz,
        label: 'Тест',
      ),
      _TypeOption(
        type: MaterialType.worksheet,
        icon: Icons.assignment,
        label: 'Рабочий лист',
      ),
      _TypeOption(
        type: MaterialType.lessonPlan,
        icon: Icons.schedule,
        label: 'План урока',
      ),
      _TypeOption(
        type: MaterialType.video,
        icon: Icons.play_circle,
        label: 'Видео',
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((option) {
        final isSelected = _selectedType == option.type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = option.type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? appAccentEnd : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? appAccentEnd : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  color: isSelected ? Colors.white : appSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : appPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector() {
    final difficulties = [
      _DifficultyOption(
        difficulty: MaterialDifficulty.beginner,
        label: 'Начальный',
        icon: Icons.stairs,
      ),
      _DifficultyOption(
        difficulty: MaterialDifficulty.intermediate,
        label: 'Средний',
        icon: Icons.trending_up,
      ),
      _DifficultyOption(
        difficulty: MaterialDifficulty.advanced,
        label: 'Продвинутый',
        icon: Icons.workspace_premium,
      ),
    ];

    return Row(
      children: difficulties.map((option) {
        final isSelected = _selectedDifficulty == option.difficulty;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDifficulty = option.difficulty;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? appAccentEnd : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? appAccentEnd : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      option.icon,
                      color: isSelected ? Colors.white : appSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.label,
                      style: GoogleFonts.montserrat(
                        color: isSelected ? Colors.white : appPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearningObjectives() {
    return Column(
      children: [
        ..._learningObjectives.asMap().entries.map((entry) {
          final index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration('Цель обучения ${index + 1}'),
                    onChanged: (value) {
                      _learningObjectives[index] = value;
                    },
                  ),
                ),
                if (_learningObjectives.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _learningObjectives.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _learningObjectives.add('');
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Добавить цель'),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(color: appSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: appAccentEnd, width: 2),
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_titleController.text.isEmpty || 
          _selectedType == null || 
          _selectedSubject == null || 
          _selectedGrade == null) {
        _showError('Пожалуйста, заполните все обязательные поля');
        return;
      }
    } else if (_currentStep == 1) {
      if (_descriptionController.text.isEmpty || _selectedDifficulty == null) {
        _showError('Пожалуйста, заполните все обязательные поля');
        return;
      }
    } else if (_currentStep == 2) {
      if (!_isFree && _priceController.text.isEmpty) {
        _showError('Пожалуйста, укажите цену или отметьте материал как бесплатный');
        return;
      }
      _submitMaterial();
      return;
    }
    
    setState(() {
      _currentStep++;
    });
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitMaterial() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final now = FieldValue.serverTimestamp();

      final materialData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'authorId': 'unknown', // TODO: replace with actual user id
        'authorName': 'Пользователь', // TODO: replace with actual user name
        'authorAvatar': '',
        'type': _selectedType?.name,
        'subject': _selectedSubject,
        'grade': _selectedGrade,
        'price': _isFree ? 0.0 : double.tryParse(_priceController.text.trim()) ?? 0.0,
        'currency': 'USD',
        'thumbnailUrl': '',
        'fileUrls': <String>[],
        'downloads': 0,
        'rating': 0.0,
        'reviewCount': 0,
        'createdAt': now,
        'updatedAt': now,
        'isPublished': false,
        'tags': _selectedTags,
        'language': 'ru',
        'fileSize': 0,
        'fileFormat': '',
        'difficulty': _selectedDifficulty?.name,
        'estimatedTime': 0,
        'previewText': _previewTextController.text.trim(),
        'learningObjectives': _learningObjectives.where((e) => e.trim().isNotEmpty).toList(),
        'isFree': _isFree,
        'isFeatured': false,
        'viewCount': 0,
        // moderation fields
        'moderationStatus': 'pending',
        'moderationComment': null,
        'moderatedBy': null,
        'moderatedAt': null,
      };

      await firestore.collection('educational_materials').add(materialData);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Text(
                'Успех!',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            'Ваш материал отправлен на модерацию. Мы проверим его в течение 24 часов.',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('ОК'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Не удалось отправить материал: $e');
    }
  }
}

class _TypeOption {
  final MaterialType type;
  final IconData icon;
  final String label;

  _TypeOption({
    required this.type,
    required this.icon,
    required this.label,
  });
}

class _DifficultyOption {
  final MaterialDifficulty difficulty;
  final String label;
  final IconData icon;

  _DifficultyOption({
    required this.difficulty,
    required this.label,
    required this.icon,
  });
}
