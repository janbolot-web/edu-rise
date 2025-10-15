import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/all_tests_provider.dart';
import '../widgets/test_card.dart';

class AllTestsPage extends ConsumerWidget {
  const AllTestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(allTestsProvider);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appPrimary,
        title: Text(
          'Все тесты (без фильтра)',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Показываются ВСЕ тесты из Firestore\n(включая draft, archived)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: testsAsync.when(
              data: (tests) {
                if (tests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Коллекция "tests" пуста',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: appPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите 🧪 для загрузки тестовых данных',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: appSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: test.status.name == 'published'
                                ? Colors.green.shade100
                                : test.status.name == 'draft'
                                ? Colors.orange.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Status: ${test.status.name}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: test.status.name == 'published'
                                  ? Colors.green.shade900
                                  : test.status.name == 'draft'
                                  ? Colors.orange.shade900
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TestCard(
                          test: test,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'ID теста: ${test.id}',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
