import 'dart:convert';

import 'package:edurise/features/lesson/presentation/widgets/description_widget.dart';
import 'package:edurise/features/lesson/presentation/widgets/example_widget.dart';
import 'package:edurise/features/lesson/presentation/widgets/lesson_button_widget.dart';
import 'package:edurise/features/lesson/presentation/widgets/lesson_image_widget.dart';
import 'package:edurise/features/lesson/presentation/widgets/small_description_widget.dart';
import 'package:flutter/material.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class LessonPage extends StatefulWidget {
  final int index;
  final int pagesCount;
  final int currentLessonNum;
  final int points;
  final dynamic lessonData;

  const LessonPage({
    super.key,
    required this.index,
    required this.pagesCount,
    required this.currentLessonNum,
    required this.points,
    this.lessonData,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late int _currentStep;
  late final PageController _pageController;
  List<dynamic>? _parts;
  late int _pagesCount;
  // selections and results per page: pageIndex -> list per-question
  final Map<int, List<int?>> _pageSelections = {};
  final Map<int, List<bool?>> _pageResults = {};

  @override
  void initState() {
    super.initState();
    // detect parts inside lessonData in multiple possible shapes
    _parts = null;
    if (widget.lessonData != null && widget.lessonData is Map) {
      final Map contents = widget.lessonData['contents'] as Map;
      dynamic candidate = contents['parts'];
      if (candidate is List) {
        _parts = List<dynamic>.from(candidate);
      }
    }
    _pagesCount = _parts?.length ?? widget.pagesCount;
    _currentStep = (widget.currentLessonNum - 1).clamp(0, _pagesCount - 1);
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(_parts);
        },
        child: Icon(Icons.info),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar at the top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: appPrimary),
                      ),

                      Expanded(
                        child: StepProgressIndicator(
                          totalSteps: _pagesCount,
                          currentStep: _currentStep + 1,
                          size: 15,
                          padding: 0,
                          selectedGradientColor: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF58A700), Color(0xFF7EC933)],
                          ),
                          unselectedGradientColor: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFE0E0E0), Color(0xFFE0E0E0)],
                          ),
                          roundedEdges: const Radius.circular(8),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.heart_broken,
                        color: Colors.red,
                      ), // placeholder for centering
                    ],
                  ),
                ],
              ),
            ),
            // Lesson content as PageView — number of pages = _pagesCount
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pagesCount,
                onPageChanged: (page) {
                  setState(() => _currentStep = page);
                },
                itemBuilder: (context, pageIndex) {
                  final part = (_parts != null && pageIndex < _parts!.length)
                      ? _parts![pageIndex]
                      : null;

                  dynamic readField(dynamic map, List<String> keys) {
                    if (map is! Map) return null;
                    for (final k in keys) {
                      if (map.containsKey(k) && map[k] != null) return map[k];
                    }
                    return null;
                  }

                  final title = readField(part, ['title'])?.toString();
                  final description = readField(part, [
                    'description',
                  ])?.toString();
                  final imageRaw = readField(part, [
                    'image_url',
                    'images',
                    'imageUrls',
                  ]);
                  // optional description text(s) after the images row (DB may store list of texts)
                  final descPicRaw = readField(part, [
                    'description_picture',
                    'descriptionPicture',
                    'description_pic',
                    'desc_image',
                  ]);
                  List<String>? images;
                  if (imageRaw is List) {
                    images = imageRaw
                        .map((e) => e?.toString() ?? '')
                        .where((s) => s.isNotEmpty)
                        .toList();
                  } else if (imageRaw is String) {
                    images = [imageRaw];
                  }
                  final explanation = readField(part, [
                    'explanation',
                  ])?.toString();
                  final sample = readField(part, ['sample'])?.toString();
                  final examplesRaw = readField(part, ['examples']);
                  final examples = (examplesRaw is List)
                      ? List<dynamic>.from(examplesRaw)
                      : null;
                  final questionsRaw = readField(part, ['questions']);
                  List<dynamic>? questionsList;
                  if (questionsRaw is List) {
                    questionsList = List<dynamic>.from(questionsRaw);
                  } else if (questionsRaw is Map) {
                    questionsList = [questionsRaw];
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок
                        if (title != null) ...[
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: appTextColor, // Duolingo-style green
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                        // Описание
                        if (description != null && description.isNotEmpty) ...[
                          DescriptionWidget(text: description),
                          const SizedBox(height: 32),
                        ],
                        // Изображения (поддержка массива ссылок)
                        if (images != null && images.isNotEmpty) ...[
                          Builder(
                            builder: (context) {
                              final screenW = MediaQuery.of(context).size.width;
                              // reserve some space for paddings and gaps; allow spaceBetween to distribute
                              final available = (screenW - 40).clamp(
                                0.0,
                                screenW.toDouble(),
                              );
                              final itemWidth =
                                  (available * 0.9) / images!.length;

                              return SizedBox(
                                height: 220,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List<Widget>.generate(images!.length, (
                                    idx,
                                  ) {
                                    final img = images![idx];
                                    return Container(
                                      width: itemWidth,
                                      // padding: const EdgeInsets.all(8),
                                      // decoration: BoxDecoration(
                                      //   color: const Color(0xFFF7F7F7),
                                      //   borderRadius: BorderRadius.circular(12),
                                      //   border: Border.all(color: const Color(0xFFE0E0E0)),
                                      // ),
                                      child: Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, st) =>
                                            const Icon(Icons.broken_image),
                                        loadingBuilder: (c, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        // description_picture может быть массивом текстов — отрендерим их в один ряд
                        if (descPicRaw is List && descPicRaw.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List<Widget>.generate(descPicRaw.length, (i) {
                              final t = descPicRaw[i];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: i < descPicRaw.length - 1 ? 12 : 0),
                                  child: SmallDescriptionWidget(text: t?.toString() ?? ''),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                        ] else if (descPicRaw is String && descPicRaw.isNotEmpty) ...[
                          SmallDescriptionWidget(text: descPicRaw),
                          const SizedBox(height: 16),
                        ],
                     

                        // Примеры
                        if (examples != null && examples.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ExamplesWidget(
                            examples: examples
                                .map((e) => e.toString())
                                .toList(),
                          ),

                          const SizedBox(height: 16),
                        ],

                        // Пример решения
                        if (sample != null && sample.isNotEmpty) ...[
                          const Text(
                            'Пример решения',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF0F4C3,
                              ), // light green background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sample,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Объяснение
                        if (explanation != null && explanation.isNotEmpty) ...[
                          const Text(
                            'Объяснение',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            explanation,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A4A4A),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Вопросы
                        if (questionsList != null &&
                            questionsList.isNotEmpty) ...[
                          const Text(
                            'Вопросы',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // prepare per-page selection/result lists
                          (() {
                            final qList = questionsList;
                            if (qList == null) return const SizedBox.shrink();
                            _pageSelections.putIfAbsent(
                              pageIndex,
                              () => List<int?>.filled(qList.length, null),
                            );
                            _pageResults.putIfAbsent(
                              pageIndex,
                              () => List<bool?>.filled(qList.length, null),
                            );

                            return Column(
                              children: List<Widget>.generate(qList.length, (
                                qi,
                              ) {
                                final q = qList[qi];
                                if (q is Map) {
                                  final qtext =
                                      q['question'] ?? q['text'] ?? q['q'];
                                  final opts = q['options'] as List?;
                                  final selected =
                                      _pageSelections[pageIndex]![qi];
                                  final result = _pageResults[pageIndex]![qi];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: result == null
                                          ? const Color(0xFFFFF9C4)
                                          : (result
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFEBEE)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          qtext?.toString() ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (opts != null)
                                          ...List<
                                            Widget
                                          >.generate(opts.length, (oi) {
                                            final opt = opts[oi];
                                            final isSelected = selected == oi;
                                            Color bg = Colors.transparent;
                                            if (result != null) {
                                              // if checked, show green for correct, red for incorrect
                                              final correctAnswer = q['answer'];
                                              bool isCorrect = false;
                                              if (correctAnswer is int) {
                                                isCorrect =
                                                    (oi == correctAnswer);
                                              } else if (correctAnswer !=
                                                  null) {
                                                isCorrect =
                                                    opts[oi].toString() ==
                                                    correctAnswer.toString();
                                              }
                                              if (isCorrect)
                                                bg = const Color(0xFFDFF0D8);
                                              else if (isSelected && !isCorrect)
                                                bg = const Color(0xFFF8D7DA);
                                            } else if (isSelected) {
                                              bg = const Color(0xFFD6E9FF);
                                            }

                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _pageSelections[pageIndex]![qi] =
                                                      oi;
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: bg,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? appPrimary
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Text(
                                                  opt.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                final sel =
                                                    _pageSelections[pageIndex]![qi];
                                                final correctAnswer =
                                                    q['answer'];
                                                bool? correct;
                                                if (sel == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Пожалуйста, выберите вариант ответа',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                if (correctAnswer is int) {
                                                  correct =
                                                      sel == correctAnswer;
                                                } else if (correctAnswer !=
                                                    null) {
                                                  final optsList = opts ?? [];
                                                  correct =
                                                      optsList[sel]
                                                          .toString() ==
                                                      correctAnswer.toString();
                                                } else {
                                                  correct =
                                                      null; // can't determine
                                                }
                                                setState(() {
                                                  _pageResults[pageIndex]![qi] =
                                                      correct;
                                                });
                                              },
                                              child: const Text('Проверить'),
                                            ),
                                            const SizedBox(width: 12),
                                            if (result != null)
                                              Text(
                                                result
                                                    ? 'Правильно'
                                                    : 'Неправильно',
                                                style: TextStyle(
                                                  color: result
                                                      ? const Color(0xFF2E7D32)
                                                      : const Color(0xFFB00020),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (q['explanation'] != null &&
                                            _pageResults[pageIndex]![qi] !=
                                                null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Объяснение: ${q['explanation']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF4A4A4A),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    q.toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }),
                            );
                          })(),
                          const SizedBox(height: 16),
                        ],

                        // Пустой контент
                        if (part == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Содержимое отсутствует',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFAAAAAA),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom navigation buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: appPrimary, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final prev = (_currentStep - 1).clamp(
                                0,
                                _pagesCount - 1,
                              );
                              _pageController.animateToPage(
                                prev,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Center(
                              child: Text(
                                'Назад',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: appPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      child: LessonButton(
                        text: 'дальше',
                        onPressed: () {
                          final lastIndex = _pagesCount - 1;
                          if (_currentStep < lastIndex) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Lesson completed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Урок завершён! ✅'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
