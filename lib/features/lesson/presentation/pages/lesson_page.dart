import 'package:flutter/material.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class LessonPage extends StatefulWidget {
  final int index;
  final int lessonCount;
  final int currentLessonNum;
  final int points;

  const LessonPage({
    super.key,
    required this.index,
    required this.lessonCount,
    required this.currentLessonNum,
    required this.points,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late int _currentStep;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentStep = (widget.currentLessonNum - 1).clamp(0, widget.lessonCount - 1);
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
                          totalSteps: widget.lessonCount,
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
                      SizedBox(width: 10,),
                      Icon(
                        Icons.heart_broken,
                        color: Colors.red,
                      ), // placeholder for centering
                    ],
                  ),
                 
                ],
              ),
            ),
            // Lesson content as PageView — number of pages = widget.lessonCount
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.lessonCount,
                onPageChanged: (page) {
                  setState(() => _currentStep = page);
                },
                itemBuilder: (context, pageIndex) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lesson content placeholder for each page
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Шаг ${pageIndex + 1}: Содержание урока',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: appPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Здесь будет содержание урока. Это может быть текст, видео, изображения и другой интерактивный контент.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              final prev = (_currentStep - 1).clamp(0, widget.lessonCount - 1);
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
                      decoration: BoxDecoration(
                        color: _currentStep < widget.lessonCount - 1
                            ? appPrimary
                            : const Color(0xFF58A700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final lastIndex = widget.lessonCount - 1;
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
                          child: Center(
                            child: Text(
                              _currentStep < widget.lessonCount - 1 ? 'Далее' : 'Завершить',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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
