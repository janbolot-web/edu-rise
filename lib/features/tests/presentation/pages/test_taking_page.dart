import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import '../../domain/models/test.dart';
import '../../domain/models/question.dart';
import '../../domain/models/test_attempt.dart';
import '../providers/test_providers.dart';
import 'test_results_page.dart';

class TestTakingPage extends ConsumerStatefulWidget {
  final String testId;

  const TestTakingPage({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<TestTakingPage> createState() => _TestTakingPageState();
}

class _QuestionImage extends StatelessWidget {
  final String src;
  const _QuestionImage({required this.src});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      src: src,
      fallbackAsset: 'assets/images/card-2.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    );
  }
}

class _TestTakingPageState extends ConsumerState<TestTakingPage> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  Timer? _timer;
  int _secondsRemaining = 0;
  DateTime? _startTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int durationMinutes) {
    _secondsRemaining = durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _submitTest(ref.read(testProvider(widget.testId)).value!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final testAsync = ref.watch(testProvider(widget.testId));

    return testAsync.when(
      data: (test) {
        if (test == null) {
          return _buildErrorScaffold(context, 'Тест не найден');
        }
        if (_timer == null) {
          _startTimer(test.duration);
        }
        return _buildContent(context, test);
      },
      loading: () => _buildLoadingScaffold(context),
      error: (error, stack) => _buildErrorScaffold(context, error.toString()),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: appAccentEnd),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: appPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Test test) {
    final currentQuestion = test.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == test.questions.length - 1;

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: appBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: appPrimary),
            onPressed: () => _showExitDialog(context),
          ),
          title: Text(
            test.title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _secondsRemaining < 60
                        ? Colors.red.withOpacity(0.1)
                        : appBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: _secondsRemaining < 60 ? Colors.red : appPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              _secondsRemaining < 60 ? Colors.red : appPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressIndicator(test),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionCard(currentQuestion),
                    const SizedBox(height: 24),
                    _buildAnswerOptions(currentQuestion),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(test, isLastQuestion),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Test test) {
    final progress = (_currentQuestionIndex + 1) / test.questions.length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопрос ${_currentQuestionIndex + 1} из ${test.questions.length}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appAccentEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: appBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(appAccentEnd),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [appAccentStart, appAccentEnd],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${question.points} ${_getPointsWord(question.points)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.text,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appPrimary,
              height: 1.4,
            ),
          ),
          if (question.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _QuestionImage(src: question.imageUrl!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question);
      case QuestionType.shortAnswer:
        return _buildShortAnswerField(question);
    }
  }

  Widget _buildMultipleChoiceOptions(Question question) {
    return Column(
      children: question.options.map((option) {
        final isSelected = _answers[question.id] == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[question.id] = option;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? appAccentEnd.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? appAccentEnd : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? appAccentEnd : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? appAccentEnd : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: appPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(Question question) {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            question,
            'Правда',
            'true',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTrueFalseButton(
            question,
            'Ложь',
            'false',
            Icons.cancel,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton(
    Question question,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _answers[question.id] == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[question.id] = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : appSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswerField(Question question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Введите ваш ответ',
          hintStyle: GoogleFonts.montserrat(color: appSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: appAccentEnd, width: 2),
          ),
        ),
        style: GoogleFonts.montserrat(
          fontSize: 16,
          color: appPrimary,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildNavigationButtons(Test test, bool isLastQuestion) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: appAccentEnd, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Назад',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: appAccentEnd,
                  ),
                ),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [appAccentStart, appAccentEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (isLastQuestion) {
                          _submitTest(test);
                        } else {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isLastQuestion ? 'Завершить' : 'Далее',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest(Test test) async {
    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Необходимо войти в систему')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    int score = 0;
    final incorrectQuestions = <String>[];

    for (final question in test.questions) {
      final userAnswer = _answers[question.id];
      if (userAnswer != null &&
          userAnswer.trim().toLowerCase() ==
              question.correctAnswer.trim().toLowerCase()) {
        score += question.points;
      } else {
        incorrectQuestions.add(question.id);
      }
    }

    final percentage = (score / test.totalPoints) * 100;
    final isPassed = percentage >= test.passingScore;
    final timeSpent = DateTime.now().difference(_startTime!).inSeconds;

    final attempt = TestAttempt(
      id: '',
      testId: test.id,
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'User',
      answers: _answers,
      score: score,
      totalPoints: test.totalPoints,
      percentage: percentage,
      startedAt: _startTime!,
      completedAt: DateTime.now(),
      timeSpent: timeSpent,
      isPassed: isPassed,
      incorrectQuestions: incorrectQuestions,
    );

    try {
      final repository = ref.read(testRepositoryProvider);
      final attemptId = await repository.submitAttempt(attempt);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TestResultsPage(
              attemptId: attemptId,
              test: test,
              attempt: attempt.copyWith(id: attemptId),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отправке теста: $e')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Выйти из теста?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Ваш прогресс не будет сохранен.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: GoogleFonts.montserrat(color: appSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Выйти',
              style: GoogleFonts.montserrat(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getPointsWord(int points) {
    if (points == 1) return 'балл';
    if (points >= 2 && points <= 4) return 'балла';
    return 'баллов';
  }
}

extension on TestAttempt {
  TestAttempt copyWith({String? id}) {
    return TestAttempt(
      id: id ?? this.id,
      testId: testId,
      userId: userId,
      userName: userName,
      answers: answers,
      score: score,
      totalPoints: totalPoints,
      percentage: percentage,
      startedAt: startedAt,
      completedAt: completedAt,
      timeSpent: timeSpent,
      isPassed: isPassed,
      incorrectQuestions: incorrectQuestions,
    );
  }
}
