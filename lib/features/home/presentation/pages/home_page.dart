import 'package:edurise/features/home/presentation/widgets/lesson_node.dart';
import 'package:edurise/features/home/presentation/widgets/overlay_modal.dart'
    show buildOverlayModal;
import 'package:edurise/features/lesson/presentation/pages/lesson_page.dart';
import 'package:edurise/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import 'package:edurise/features/courses/domain/entities/course.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _expandedIndex;
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _nodeKeys;

  // Overlay entry for absolute modal
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _nodeKeys = List.generate(20, (_) => GlobalKey());
    _scrollController.addListener(() {
      // Close overlay when the user starts scrolling so it doesn't linger
      if (_overlayEntry != null) {
        _removeOverlay();
        return;
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  // legacy: placeholder removed — overlay positions itself in its builder

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
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
                    Expanded(
                      child: Text(
                        'Салам, окуучу!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appPrimary,
                        ),
                      ),
                    ),
                    // avatar
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(
                            'assets/images/author.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.person, color: appPrimary),
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
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff58A700),
                        blurRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Text('📚', style: TextStyle(fontSize: 36)),
                    title: Text(
                      'I Этап',
                      style: TextStyle(
                        color: Color(0xffD0F0C1),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Аналогиянын 6 негизги түрү',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              // Stack(
              //   children: [
                
              //   ],
              // ),
            
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Image.asset(
                              'assets/animations/1-emotion.gif',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              const lessonCount = 5;
                              const completedLessons = 1;
                              final points = 100 + index * 10;
                              return LessonNode(
                                key: ValueKey(index),
                                anchorKey: _nodeKeys[index],
                                isCompleted: index < 3,
                                isCurrent: index == 3,
                                index: index,
                                totalItems: 20,
                                lessonCount: lessonCount,
                                completedLessons: completedLessons,
                                points: points,
                                isExpanded: _expandedIndex == index,
                                onTap: () => _toggleOverlay(
                                  index,
                                  lessonCount: lessonCount,
                                  completedLessons: completedLessons,
                                  points: points,
                                ),
                              );
                            }, childCount: 20),
                          ),
                        ],
                      ),

                      // Decorative GIF in the empty zig-zag area (non-interactive)
                      

                      // Overlay is shown via OverlayEntry (absolute) — no local widget here
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

  void _toggleOverlay(
    int index, {
    int lessonCount = 5,
    int completedLessons = 0,
    int points = 100,
  }) {
    // If an overlay already exists, remove it (toggle behavior)
    if (_overlayEntry != null) {
      _removeOverlay();
      if (_expandedIndex == index) return; // closed the same one
    }

    final anchorContext = _nodeKeys[index].currentContext;
    if (anchorContext == null) {
      setState(() => _expandedIndex = index);
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final aContext = _nodeKeys[index].currentContext;
        if (aContext == null) return const SizedBox.shrink();
        final RenderBox aBox = aContext.findRenderObject() as RenderBox;
        final topLeft = aBox.localToGlobal(Offset.zero);
        final modalWidth = 260.0;
        double left = topLeft.dx + aBox.size.width / 2 - modalWidth / 2;
        final screenWidth = MediaQuery.of(context).size.width;
        left = left.clamp(8.0, screenWidth - modalWidth - 8.0);
        final top = topLeft.dy + aBox.size.height + 8.0;

        // Only show modal, no background layer to avoid blocking scroll
        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {}, // absorb taps inside modal
            child: buildOverlayModal(
              index,
              lessonCount: lessonCount,
              completedLessons: completedLessons,
              points: points,
              onStartTap: () {
                _removeOverlay();
                final currentLessonNum = (completedLessons < lessonCount)
                    ? (completedLessons + 1)
                    : lessonCount;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonPage(
                      index: index,
                      lessonCount: lessonCount,
                      currentLessonNum: currentLessonNum,
                      points: points,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _expandedIndex = index);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _expandedIndex = null);
  }
}

class CourseCard extends StatelessWidget {
  final int index;
  const CourseCard({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xffFFAC71), const Color(0xffFF8450)],
      [const Color(0xff02AAB0), const Color(0xff00CDAC)],
      [const Color(0xFF6C5CFF), const Color(0xFF4E3BFF)],
      [const Color(0xFF4AD3FF), const Color(0xFF00B7FF)],
    ];
    final grad = gradients[index % gradients.length];

    return SizedBox(
      width: 260,
      child: Stack(
        children: [
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: grad,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: grad.last.withAlpha(51),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/card-${(index % 2) + 1}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const FlutterLogo(size: 88),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Поиск соучредителя\nна раннем этапе',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage('assets/images/author.png'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Анкур Варику',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/icon-play.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MentorPill extends StatelessWidget {
  final int index;
  const MentorPill({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final bgGradients = [
      [const Color(0xFF4C9BFF), const Color(0xFF1E7BFF)],
      [const Color(0xFF666666), const Color(0xFF222222)],
      [const Color(0xFF6C5CFF), const Color(0xFF5043FF)],
      [const Color(0xFF00C7B7), const Color(0xFF00A89A)],
    ];
    final bg = bgGradients[index % bgGradients.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/author.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Анкур Варику',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Основатель Nearby | Ментор',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final List<String>? gradientHex;

  const HomeCourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.gradientHex,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> grad;
    if (gradientHex != null && gradientHex!.isNotEmpty) {
      grad = gradientHex!.map((h) {
        var hex = h.replaceAll('#', '').trim();
        if (hex.length == 6) hex = 'FF$hex';
        final value = int.tryParse(hex, radix: 16) ?? 0xFFFFFFFF;
        return Color(value);
      }).toList();
    } else {
      final defaults = [
        [const Color(0xffFFAC71), const Color(0xffFF8450)],
        [const Color(0xff02AAB0), const Color(0xff00CDAC)],
        [const Color(0xFF6C5CFF), const Color(0xFF4E3BFF)],
        [const Color(0xFF4AD3FF), const Color(0xFF00B7FF)],
      ];
      grad = defaults[course.id.hashCode % defaults.length];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: grad.last.withAlpha(40),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: SafeNetworkImage(
                        src: course.imageUrl,
                        fallbackAsset: 'assets/images/card-1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: AssetImage('assets/images/author.png'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.author,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 0,
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  'assets/images/icon-play.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
