import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/test.dart';
import '../providers/test_providers.dart';
import '../widgets/test_card.dart';
import '../widgets/stats_card.dart';
import 'all_tests_page.dart';
import 'create_index_page.dart';

class TestsPage extends ConsumerStatefulWidget {
  const TestsPage({super.key});

  @override
  ConsumerState<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends ConsumerState<TestsPage> {
  String _selectedTab = 'all';

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(testFiltersProvider);
    final testsAsync = ref.watch(testsProvider(filters));

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Проверьте свои знания',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 22),
              _buildTabs(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StatsCard(),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Доступные тесты',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: appPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllTestsPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Все тесты',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: appAccentEnd,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              testsAsync.when(
                data: (tests) => _buildTestsList(tests),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) {
                  final errorMsg = error.toString();
                  if (errorMsg.contains('requires an index') ||
                      errorMsg.contains('failed-precondition')) {
                    return _buildIndexError();
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Ошибка: $error'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }


  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFFBEC8D6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Поиск тестов',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFBEC8D6),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [appAccentStart, appAccentEnd],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: appAccentEnd.withAlpha(102),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTab('all', 'Все тесты'),
          const SizedBox(width: 12),
          _buildTab('my_tests', 'Мои тесты'),
          const SizedBox(width: 12),
          _buildTab('favorites', 'Избранное'),
          const SizedBox(width: 12),
          _buildTab('completed', 'Пройденные'),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? appAccentEnd : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: appAccentEnd.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : appSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTestsList(List<Test> tests) {
    if (tests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: appSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Тесты не найдены',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: appSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    '💡 Как загрузить тесты:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHintItem('1️⃣', 'Нажмите оранжевую кнопку 🧪 внизу'),
                  _buildHintItem('2️⃣', 'Выберите "Создать тестовые тесты"'),
                  _buildHintItem('3️⃣', 'Подождите ~3 секунды'),
                  _buildHintItem('4️⃣', 'Готово! Тесты появятся здесь'),
                  const SizedBox(height: 12),
                  Text(
                    'Или нажмите 🐛 для диагностики',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tests.map((test) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: TestCard(
            test: test,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/test-details',
                arguments: test.id,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget? _buildFAB() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'zipgrade_actions',
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Создать бланк (ZipGrade)'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/zipgrade-sheet');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.document_scanner),
                      title: const Text('Сканировать ответы (ZipGrade)'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/zipgrade-scan');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: appAccentEnd,
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: Text(
            'ZipGrade',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        FloatingActionButton.extended(
          heroTag: 'create_test',
          onPressed: () {
            Navigator.pushNamed(context, '/create-test');
          },
          backgroundColor: appAccentEnd,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Создать тест',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHintItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Требуется индекс Firestore',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Тесты созданы ✅, но для их отображения нужно создать индекс в Firebase',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: appSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateIndexPage(),
                  ),
                );
              },
              icon: const Icon(Icons.construction, color: Colors.white),
              label: Text(
                'Создать индекс (30 сек)',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentEnd,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
