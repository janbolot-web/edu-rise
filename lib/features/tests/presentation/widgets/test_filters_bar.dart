import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/test.dart';
import '../providers/test_providers.dart';

class TestFiltersBar extends StatefulWidget {
  final Function(TestFilters) onFilterChanged;

  const TestFiltersBar({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<TestFiltersBar> createState() => _TestFiltersBarState();
}

class _TestFiltersBarState extends State<TestFiltersBar> {
  String? _selectedSubject;
  int? _selectedGrade;
  TestDifficulty? _selectedDifficulty;
  String _sortBy = 'recent';

  final List<String> subjects = [
    'Математика',
    'Русский язык',
    'Литература',
    'Английский язык',
    'Физика',
    'Химия',
    'Биология',
    'История',
    'География',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(
            label: _selectedSubject ?? 'Предмет',
            icon: Icons.school_outlined,
            onTap: () => _showSubjectPicker(),
            isActive: _selectedSubject != null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedGrade != null ? '$_selectedGrade класс' : 'Класс',
            icon: Icons.class_outlined,
            onTap: () => _showGradePicker(),
            isActive: _selectedGrade != null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedDifficulty != null ? _getDifficultyLabel() : 'Сложность',
            icon: Icons.speed_outlined,
            onTap: () => _showDifficultyPicker(),
            isActive: _selectedDifficulty != null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _getSortLabel(),
            icon: Icons.sort,
            onTap: () => _showSortPicker(),
            isActive: _sortBy != 'recent',
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(width: 8),
            _buildClearButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? appAccentEnd : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : appSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : appSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _clearFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: appAccentEnd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.clear,
              size: 18,
              color: appAccentEnd,
            ),
            const SizedBox(width: 8),
            Text(
              'Очистить',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appAccentEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите предмет',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...subjects.map((subject) => ListTile(
              title: Text(
                subject,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: appPrimary,
                ),
              ),
              onTap: () {
                setState(() => _selectedSubject = subject);
                _applyFilters();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showGradePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите класс',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(11, (i) => i + 1).map((grade) => ListTile(
              title: Text(
                '$grade класс',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: appPrimary,
                ),
              ),
              onTap: () {
                setState(() => _selectedGrade = grade);
                _applyFilters();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите сложность',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Легкий', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _selectedDifficulty = TestDifficulty.easy);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Средний', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _selectedDifficulty = TestDifficulty.medium);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Сложный', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _selectedDifficulty = TestDifficulty.hard);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сортировать по',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Новые', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _sortBy = 'recent');
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Популярные', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _sortBy = 'popular');
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Рейтинг', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                setState(() => _sortBy = 'rating');
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    widget.onFilterChanged(TestFilters(
      subject: _selectedSubject,
      gradeLevel: _selectedGrade,
      difficulty: _selectedDifficulty,
      sortBy: _sortBy,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedGrade = null;
      _selectedDifficulty = null;
      _sortBy = 'recent';
    });
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return _selectedSubject != null ||
        _selectedGrade != null ||
        _selectedDifficulty != null ||
        _sortBy != 'recent';
  }

  String _getDifficultyLabel() {
    switch (_selectedDifficulty!) {
      case TestDifficulty.easy:
        return 'Легкий';
      case TestDifficulty.medium:
        return 'Средний';
      case TestDifficulty.hard:
        return 'Сложный';
    }
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'recent':
        return 'Новые';
      case 'popular':
        return 'Популярные';
      case 'rating':
        return 'Рейтинг';
      default:
        return 'Сортировка';
    }
  }
}
