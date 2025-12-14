// Compact, single-definition HomePage without duplicates
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/features/home/presentation/providers/subject_providers.dart';
import 'package:edurise/features/home/presentation/widgets/lesson_node.dart';
import 'package:edurise/features/home/presentation/widgets/overlay_modal.dart'
    show buildOverlayModal;
import 'package:edurise/features/home/presentation/utils/lesson_tree_builder.dart';
import 'package:edurise/features/home/presentation/widgets/overlay_portal.dart';
import 'package:edurise/features/lesson/presentation/pages/lesson_page.dart';
import 'package:edurise/features/profile/presentation/pages/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int? _expandedIndex;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _nodeKeys = [];

  // Active overlay remover (if any)
  OverlayRemover? _activeOverlayRemover;
  bool _scrollControllerInitialized = false;

  // Memoization for items
  List<LessonTreeItem> _memoizedItems = [];
  Object? _lastSubjectSnapshot;

  @override
  void dispose() {
    _removeActiveOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureNodeKeys(int count) {
    if (_nodeKeys.length >= count) return;
    _nodeKeys.addAll(
      List.generate(count - _nodeKeys.length, (_) => GlobalKey()),
    );
  }

  ScrollController _scrollControllerSafe() {
    if (!_scrollControllerInitialized) {
      _scrollControllerInitialized = true;
      _scrollController.addListener(() {
        _removeActiveOverlay();
      });
    }
    return _scrollController;
  }

  void _showOverlayForNode({
    required int index,
    required GlobalKey anchorKey,
    required Widget modalChild,
  }) {
    // Close existing overlay if present
    _activeOverlayRemover?.call();
    // Show new overlay portal; it returns a remover that triggers the closing animation
    final remover = showOverlayPortal(
      context: context,
      anchorKey: anchorKey,
      child: modalChild,
      scrollController: _scrollController,
      onClosed: () {
        if (mounted) setState(() => _expandedIndex = null);
      },
    );

    _activeOverlayRemover = remover;
    setState(() => _expandedIndex = index);
  }

  void _removeActiveOverlay() {
    _activeOverlayRemover?.call();
    _activeOverlayRemover = null;
    if (mounted) setState(() => _expandedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final subjectAsync = ref.watch(getSubjectProvider('analogy'));
    final subject = subjectAsync.asData?.value;

    // Memoize items so they rebuild only when subject changes
    if (!identical(subject, _lastSubjectSnapshot)) {
      _lastSubjectSnapshot = subject;
      _memoizedItems = LessonTreeBuilder.build(subject);
      final nodeCount = _memoizedItems
          .where((e) => e.type == ItemType.moduleNode)
          .length;
      _ensureNodeKeys(nodeCount);
    }
    final items = _memoizedItems;

    return Scaffold(
      backgroundColor: appBackground,
      floatingActionButton: FloatingActionButton(onPressed: () { print(subject);}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: appPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Салам, окуучу!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(
                            'assets/images/author.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: appPrimary2,
                    borderRadius: const BorderRadius.all(Radius.circular(13)),
                  ),
                  child: ListTile(
                    leading: const Text('📚', style: TextStyle(fontSize: 36)),
                    title: const Text(
                      'I Этап',
                      style: TextStyle(
                        color: Color(0xffD0F0C1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Аналогиянын 6 негизги түрү',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: subjectAsync.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : subjectAsync.hasError
                      ? Center(
                          child: Text(
                            'Error loading subject: ${subjectAsync.error}',
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Center(
                                  child: Image.asset(
                                    'assets/animations/1-emotion.gif',
                                    width: 140,
                                    height: 140,
                                  ),
                                ),
                              ),
                            ),
                            CustomScrollView(
                              controller: _scrollControllerSafe(),
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    if (items.isEmpty)
                                      return const SizedBox.shrink();
                                    final item = items[index];
                                    if (item.type == ItemType.stageHeader) {
                                      final si = item.stageIndex;
                                      final stage = subject!.stages[si];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Divider(thickness: 1),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: Text(
                                                stage.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const Expanded(
                                              child: Divider(thickness: 1),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      final si = item.stageIndex;
                                      final mi = item.moduleIndex!;
                                      final nodeIdx = item.nodeIndex!;
                                        final moduleData = subject!.stages[si].modules[mi];
                                        final lessonsList = (moduleData['module'] as List);
                                        final lessonCount = lessonsList.length;
                                      const pagesPerLesson = 3;
                                      const completedLessons = 0;
                                      final int points = 100 + nodeIdx * 10;
                                      final anchorKey =
                                          (nodeIdx < _nodeKeys.length)
                                          ? _nodeKeys[nodeIdx]
                                          : GlobalKey();
                                      final modal = buildOverlayModal(
                                          nodeIdx,
                                          lessonCount: lessonCount,
                                          completedLessons: completedLessons,
                                          points: points,
                                          lesson: lessonsList.isNotEmpty ? lessonsList[0] : null,
                                          onStartTap: (lesson) {
                                            _removeActiveOverlay();
                                            final currentLessonNum =
                                                (completedLessons < lessonCount)
                                                ? (completedLessons + 1)
                                                : lessonCount;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LessonPage(
                                                  index: nodeIdx,
                                                  pagesCount: pagesPerLesson,
                                                  currentLessonNum: currentLessonNum,
                                                  points: points,
                                                  lessonData: lesson,
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                      return LessonNode(
                                        key: ValueKey('$si-$mi'),
                                        anchorKey: anchorKey,
                                        isCompleted: nodeIdx < 3,
                                        isCurrent: nodeIdx == 0,
                                        index: nodeIdx,
                                        totalItems: 20,
                                        lessonCount: lessonCount,
                                        completedLessons: completedLessons,
                                        points: points,
                                        isExpanded: _expandedIndex == nodeIdx,
                                        onTap: () => _showOverlayForNode(
                                          index: nodeIdx,
                                          anchorKey: anchorKey,
                                          modalChild: modal,
                                        ),
                                      );
                                    }
                                  }, childCount: items.length),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
