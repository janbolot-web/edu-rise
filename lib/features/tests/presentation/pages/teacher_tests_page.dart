import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/test.dart';
import 'create_test_page.dart';
import 'test_analytics_page.dart';

final teacherTestsProvider = StreamProvider<List<Test>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('tests')
      .where('teacherId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Test.fromFirestore(doc)).toList());
});

class TeacherTestsPage extends ConsumerStatefulWidget {
  const TeacherTestsPage({super.key});

  @override
  ConsumerState<TeacherTestsPage> createState() => _TeacherTestsPageState();
}

class _TeacherTestsPageState extends ConsumerState<TeacherTestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(teacherTestsProvider);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Мои тесты',
          style: GoogleFonts.montserrat(
            color: appPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: appAccentEnd,
          unselectedLabelColor: appSecondary,
          indicatorColor: appAccentEnd,
          tabs: const [
            Tab(text: 'Черновики'),
            Tab(text: 'Опубликованные'),
            Tab(text: 'Архив'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: testsAsync.when(
              data: (tests) => _buildTabContent(tests),
              loading: () => const Center(child: CircularProgressIndicator(color: appAccentEnd)),
              error: (error, _) => Center(
                child: Text('Ошибка: $error', style: GoogleFonts.montserrat()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Создать тест'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTestPage()));
                    },
                  ),
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
        icon: const Icon(Icons.add),
        label: Text('Создать', style: GoogleFonts.montserrat()),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Поиск тестов...',
          prefixIcon: const Icon(Icons.search, color: appSecondary),
          filled: true,
          fillColor: appBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildTabContent(List<Test> allTests) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTestList(allTests, TestStatus.draft),
        _buildTestList(allTests, TestStatus.published),
        _buildTestList(allTests, TestStatus.archived),
      ],
    );
  }

  Widget _buildTestList(List<Test> allTests, TestStatus status) {
    final tests = allTests
        .where((t) => t.status == status)
        .where((t) =>
            _searchQuery.isEmpty ||
            t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: appSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Нет тестов',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: appSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) => _buildTestCard(tests[index]),
    );
  }

  Widget _buildTestCard(Test test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (test.coverImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                test.coverImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(test.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusLabel(test.status),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: _getStatusColor(test.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appAccentEnd.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        test.subject,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: appAccentEnd,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  test.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: appPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  test.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: appSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.quiz, '${test.questions.length} вопросов'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.timer, '${test.duration} мин'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.people, '${test.attempts} попыток'),
                  ],
                ),
                if (test.status == TestStatus.published) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${test.averageScore.toStringAsFixed(1)}% средний балл',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: appSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateTestPage(existingTest: test),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Редактировать'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: appPrimary,
                          side: const BorderSide(color: appSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (test.status == TestStatus.published)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TestAnalyticsPage(testId: test.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics, size: 18),
                          label: const Text('Аналитика'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appAccentEnd,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showDeleteDialog(test),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: appSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TestStatus status) {
    switch (status) {
      case TestStatus.draft:
        return Colors.orange;
      case TestStatus.published:
        return Colors.green;
      case TestStatus.archived:
        return Colors.grey;
    }
  }

  String _getStatusLabel(TestStatus status) {
    switch (status) {
      case TestStatus.draft:
        return 'Черновик';
      case TestStatus.published:
        return 'Опубликован';
      case TestStatus.archived:
        return 'Архив';
    }
  }

  void _showDeleteDialog(Test test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Удалить тест?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Вы уверены, что хотите удалить "${test.title}"? Это действие нельзя отменить.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(testRepositoryProvider).deleteTest(test.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Тест удалён')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
