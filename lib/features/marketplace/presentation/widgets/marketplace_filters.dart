import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/educational_material.dart' as em;

class MarketplaceFilters extends StatefulWidget {
  final Function(FilterOptions) onFiltersChanged;
  final FilterOptions? initialFilters;

  const MarketplaceFilters({
    super.key,
    required this.onFiltersChanged,
    this.initialFilters,
  });

  @override
  State<MarketplaceFilters> createState() => _MarketplaceFiltersState();
}

class _MarketplaceFiltersState extends State<MarketplaceFilters> {
  // local state
  List<String> _selectedSubjects = [];
  List<String> _selectedGrades = [];
  List<em.MaterialType> _selectedTypes = [];
  List<em.MaterialDifficulty> _selectedDifficulties = [];
  double _priceMin = 0.0;
  double _priceMax = 1000.0;
  RatingRange _ratingRange = const RatingRange();
  bool _freeOnly = false;
  bool _featuredOnly = false;
  String _searchQuery = '';
  SortOption _sortBy = SortOption.newest;
  String _language = '';

  final List<String> _subjects = const [
    'Математика',
    'Русский язык',
    'История',
    'Физика',
    'Химия',
    'Биология',
    'География',
    'Английский язык',
    'Литература',
    'Информатика',
  ];

  final List<String> _grades = const [
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
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    if (f == null) return;
    final dyn = f as dynamic;
    // safe dynamic extraction: works even if generated getters are absent
    try {
      _selectedSubjects = List<String>.from(dyn.subjects ?? []);
    } catch (_) {}
    try {
      _selectedGrades = List<String>.from(dyn.grades ?? []);
    } catch (_) {}
    try {
      _selectedTypes = List<em.MaterialType>.from(dyn.types ?? []);
    } catch (_) {}
    try {
      _selectedDifficulties = List<em.MaterialDifficulty>.from(dyn.difficulties ?? []);
    } catch (_) {}
    try {
      final pr = dyn.priceRange;
      _priceMin = (pr?.min as double?) ?? _priceMin;
      _priceMax = (pr?.max as double?) ?? _priceMax;
    } catch (_) {}
    try {
      _ratingRange = dyn.ratingRange as RatingRange;
    } catch (_) {}
    try {
      _freeOnly = dyn.freeOnly as bool;
    } catch (_) {}
    try {
      _featuredOnly = dyn.featuredOnly as bool;
    } catch (_) {}
    try {
      _searchQuery = dyn.searchQuery as String;
    } catch (_) {}
    try {
      _sortBy = dyn.sortBy as SortOption;
    } catch (_) {}
    try {
      _language = dyn.language as String;
    } catch (_) {}
  }

  void _updateFilters() {
    widget.onFiltersChanged(FilterOptions(
      subjects: _selectedSubjects,
      grades: _selectedGrades,
      types: _selectedTypes,
      difficulties: _selectedDifficulties,
      priceRange: PriceRange(min: _priceMin, max: _priceMax),
      ratingRange: _ratingRange,
      freeOnly: _freeOnly,
      featuredOnly: _featuredOnly,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
      language: _language,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Фильтры',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: appPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSubjects = [];
                    _selectedGrades = [];
                    _selectedTypes = [];
                    _selectedDifficulties = [];
                    _priceMin = 0.0;
                    _priceMax = 1000.0;
                    _ratingRange = const RatingRange();
                    _freeOnly = false;
                    _featuredOnly = false;
                    _searchQuery = '';
                    _sortBy = SortOption.newest;
                    _language = '';
                  });
                  _updateFilters();
                },
                child: Text(
                  'Сбросить',
                  style: GoogleFonts.montserrat(
                    color: appSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Range
          Text(
            'Цена',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceField('От', _priceMin, (v) {
                  setState(() => _priceMin = v);
                  _updateFilters();
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceField('До', _priceMax, (v) {
                  setState(() => _priceMax = v);
                  _updateFilters();
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Free Only
          Row(
            children: [
              Checkbox(value: _freeOnly, onChanged: (val) {
                setState(() => _freeOnly = val ?? false);
                _updateFilters();
              }, activeColor: appAccentEnd),
              const SizedBox(width: 8),
              Text('Только бесплатные', style: GoogleFonts.montserrat(fontSize: 16, color: appPrimary)),
            ],
          ),
          const SizedBox(height: 20),

          // Subjects
          Text('Предметы', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: appPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _subjects.map((s) {
              final sel = _selectedSubjects.contains(s);
              return FilterChip(
                label: Text(s),
                selected: sel,
                onSelected: (v) {
                  setState(() {
                    final copy = List<String>.from(_selectedSubjects);
                    if (v) {
                      copy.add(s);
                    } else {
                      copy.remove(s);
                    }
                    _selectedSubjects = copy;
                  });
                  _updateFilters();
                },
                selectedColor: appAccentEnd.withOpacity(0.2),
                checkmarkColor: appAccentEnd,
                labelStyle: GoogleFonts.montserrat(color: sel ? appAccentEnd : appPrimary, fontWeight: FontWeight.w500),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Grades
          Text('Классы', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: appPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _grades.map((g) {
              final sel = _selectedGrades.contains(g);
              return FilterChip(
                label: Text(g),
                selected: sel,
                onSelected: (v) {
                  setState(() {
                    final copy = List<String>.from(_selectedGrades);
                    if (v) {
                      copy.add(g);
                    } else {
                      copy.remove(g);
                    }
                    _selectedGrades = copy;
                  });
                  _updateFilters();
                },
                selectedColor: appAccentEnd.withOpacity(0.2),
                checkmarkColor: appAccentEnd,
                labelStyle: GoogleFonts.montserrat(color: sel ? appAccentEnd : appPrimary, fontWeight: FontWeight.w500),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: appSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (text) {
            final v = double.tryParse(text) ?? 0.0;
            onChanged(v);
          },
          decoration: InputDecoration(
            hintText: value == 0.0 ? '₽' : value.toString(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: appSecondary.withOpacity(0.3))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: GoogleFonts.montserrat(fontSize: 14, color: appPrimary),
        ),
      ],
    );
  }
}
