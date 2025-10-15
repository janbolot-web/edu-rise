import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/features/ai_chat/presentation/viewmodels/ai_chat_viewmodel.dart';
import 'package:edurise/features/ai_chat/presentation/pages/image_library_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:edurise/features/ai_chat/presentation/providers/chat_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:edurise/features/ai_chat/presentation/widgets/loading_pdf_card.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon.isNotEmpty ? Image.asset(icon, width: 22, height: 22) : SizedBox(),
              icon.isNotEmpty ? const SizedBox(width: 8) : SizedBox(),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final VoidCallback onTap;

  const _WelcomeActionCard({
    required this.title,
    required this.description,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the card sizes itself to its intrinsic content width and
    // does not expand to fill available horizontal space (useful inside Wrap/Row).
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicWidth(
        stepWidth: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appSecondary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: appPrimary.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon.isNotEmpty
                  ? Image.asset(icon, width: 22, height: 22)
                  : const SizedBox.shrink(),
              icon.isNotEmpty ? const SizedBox(width: 8) : const SizedBox.shrink(),
              Text(
                title,
                style: TextStyle(
                  color: appPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiChatPageState extends ConsumerState<AiChatPage> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _listening = false;
  Timer? _scrollDebounce;
  Timer? _followTypingTimer;
  bool _userIsInteracting = false;
  bool _showMoreActions = false;
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerSlideAnimation;

  // Определяем, является ли сообщение тестовым.
  // Сначала пробуем явно использовать поле `isTest` если оно существует (backwards-compatible),
  // затем используем простые эвристики по тексту (метки [test], слова "тест").
  bool _isTestMessage(dynamic m) {
    try {
      // Если в модели есть поле isTest — используем его
      if (m != null) {
        final dyn = m as dynamic;
        if (dyn.isTest is bool) return dyn.isTest as bool;
      }
    } catch (_) {}

    final txt = (m?.text ?? '').toString().toLowerCase();
    if (txt.startsWith('[test]') ||
        txt.startsWith('test') ||
        txt.startsWith('тест') ||
        txt.contains('[test]') ||
        txt.contains('тестов')) {
      return true;
    }
    return false;
  }

  bool isLongMessage = false;

  @override
  void initState() {
    super.initState();
    
    // Инициализируем анимацию для drawer
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _drawerSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Прокручиваем к последнему сообщению при открытии чата
    // Используем задержку, чтобы ListView успел построиться
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollToBottom(smooth: false);
        }
      });
    });
  }

  // speech-to-text removed due to crashes on some devices
  void _scrollToBottom({bool smooth = true}) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final now = _scrollController.offset;
    final gap = (max - now).abs();

    // Если почти внизу — используем jumpTo для мгновенного скролла
    if (gap < 80) {
      try {
        _scrollController.jumpTo(max);
      } catch (_) {}
      return;
    }

    // Для больших расстояний используем анимацию
    if (smooth) {
      try {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      } catch (_) {}
    } else {
      try {
        _scrollController.jumpTo(max);
      } catch (_) {}
    }
  }

  void _scheduleAutoScroll({bool force = false}) {
    // Не скроллим если пользователь активно взаимодействует (кроме force)
    if (_userIsInteracting && !force) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final isNearBottom = maxScroll - currentScroll < 300;

      // Скроллим только если пользователь близко к низу или force
      if (isNearBottom || force) {
        _scrollToBottom(smooth: false);
      }
    });
  }

  void _startFollowTyping() {
    _followTypingTimer ??= Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) {
      if (!_scrollController.hasClients) return;

      try {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        final gap = (max - current).abs();

        // Принудительно скроллим к концу при печати ИИ
        if (gap > 10) {
          // Если не в самом низу
          _scrollController.jumpTo(max);
        }
      } catch (_) {}
    });
  }

  void _stopFollowTyping() {
    _followTypingTimer?.cancel();
    _followTypingTimer = null;
  }

  // voice input removed

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _scrollDebounce?.cancel();
    _followTypingTimer?.cancel();
    _drawerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we attempt speech initialization once after first frame to avoid platform-channel calls during build.
    // speech removed: no deferred initialization
    // Register listener once in build (allowed for Riverpod's ref.listen in build)
    if (!_listening) {
      _listening = true;
      ref.listen<AiChatState>(aiChatViewModelProvider, (prev, next) {
        // Проверяем, есть ли изменения в сообщениях
        final hasNewMessages = prev?.messages.length != next.messages.length;

        // Включаем постоянное "следование" при печати ИИ
        final lastMessage = next.messages.isNotEmpty
            ? next.messages.last
            : null;
        final isBotTyping =
            lastMessage != null &&
            !lastMessage.isUser &&
            lastMessage.isLoading &&
            !lastMessage.isGeneratingPdf; // Не следуем при генерации PDF

        if (isBotTyping) {
          _startFollowTyping();
        } else {
          _stopFollowTyping();
        }

        // Скроллим при новых сообщениях
        if (hasNewMessages) {
          _scheduleAutoScroll(force: false);
        }
      });
    }

    final state = ref.watch(aiChatViewModelProvider);
    final messages = state.messages;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            const SizedBox(width: 12),
            const Text(
              'AI Чат',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: appPrimary),
        actions: [
          IconButton(
            tooltip: 'Новый чат',
            icon: Image.asset('assets/icons/newAddChat-icon.png', width: 28, height: 28),
            onPressed: () async {
              await ref.read(aiChatViewModelProvider.notifier).createNewChat();
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Меню',
                icon:Image.asset('assets/icons/menu-icon.png', width: 28, height: 28),
                onPressed: () {
                  _drawerAnimationController.forward();
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: _buildHistoryDrawer(ref),
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) {
          _drawerAnimationController.reset();
        }
      },
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeScreen(ref)
                : Listener(
                    onPointerDown: (PointerDownEvent _) {
                      _userIsInteracting = true;
                    },
                    onPointerUp: (PointerUpEvent _) {
                      _userIsInteracting = false;
                    },
                    onPointerCancel: (PointerCancelEvent _) {
                      _userIsInteracting = false;
                    },
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction == ScrollDirection.forward ||
                            notification.direction == ScrollDirection.reverse) {
                          // Пользователь активно скроллит
                          _userIsInteracting = true;
                          // Сбрасываем флаг через небольшую задержку после остановки
                          _scrollDebounce?.cancel();
                          _scrollDebounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              _userIsInteracting = false;
                            },
                          );
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          final align = m.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft;

                          final radius = BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(m.isUser ? 16 : 4),
                            bottomRight: Radius.circular(m.isUser ? 4 : 16),
                          );
                          return Align(
                            alignment: align,
                            child: GestureDetector(
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.copy),
                                          title: const Text('Копировать'),
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: m.text),
                                            );
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Текст скопирован',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                        if (_isTestMessage(m) &&
                                            (m.filePath == null ||
                                                m.filePath!.isEmpty) &&
                                            (m.quickOptions == null ||
                                                m.quickOptions!.isEmpty))
                                          InkWell(
                                            onTap: () async {
                                              await ref
                                                  .read(
                                                    aiChatViewModelProvider
                                                        .notifier,
                                                  )
                                                  .createPdfFromText(
                                                    m.text,
                                                    title: 'Документ',
                                                  );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: appAccentEnd.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 16,
                                                    color: appAccentEnd,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'PDF',
                                                    style: TextStyle(
                                                      color: appAccentEnd,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (!m.isUser &&
                                            m.text.length > 100 &&
                                            _isTestMessage(m) &&
                                            (m.filePath == null ||
                                                m.filePath!.isEmpty) &&
                                            (m.quickOptions == null ||
                                                m.quickOptions!.isEmpty)) ...[
                                          ListTile(
                                            leading: const Icon(
                                              Icons.picture_as_pdf,
                                            ),
                                            title: const Text('Создать PDF'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              await ref
                                                  .read(
                                                    aiChatViewModelProvider
                                                        .notifier,
                                                  )
                                                  .createPdfFromText(
                                                    m.text,
                                                    title: 'Документ',
                                                  );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.85,
                                ),
                                child: Column(
                                  crossAxisAlignment: m.isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    // Пузырь сообщения
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: m.isUser ? null : Colors.white,
                                        gradient: m.isUser
                                            ? const LinearGradient(
                                                colors: [
                                                  appAccentStart,
                                                  appAccentEnd,
                                                ],
                                              )
                                            : null,
                                        borderRadius: radius,
                                        boxShadow: [
                                          if (!m.isUser)
                                            BoxShadow(
                                              color: appPrimary.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                        ],
                                        border: m.isUser
                                            ? null
                                            : Border.all(
                                                color: appSecondary.withOpacity(
                                                  0.12,
                                                ),
                                              ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          switchInCurve: Curves.easeInOut,
                                          switchOutCurve: Curves.easeInOut,
                                          transitionBuilder:
                                              (child, animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: ScaleTransition(
                                                    scale: Tween<double>(
                                                      begin: 0.95,
                                                      end: 1.0,
                                                    ).animate(animation),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                          child: Builder(
                                            key: ValueKey(
                                              '${m.isLoading}_${m.filePath}_${m.text}_${m.isGeneratingPdf}',
                                            ),
                                            builder: (_) {
                                              // Специальный лоадер для генерации PDF
                                              if (m.isGeneratingPdf &&
                                                  m.isLoading) {
                                                return RotatingBorderContainer();
                                              }

                                              // Обычный лоадер для печатающегося текста ИИ
                                              if (m.isLoading &&
                                                  !m.isUser &&
                                                  m.text.isNotEmpty) {
                                                return MarkdownBody(
                                                  data: m.text,
                                                  styleSheet:
                                                      MarkdownStyleSheet(
                                                        p: TextStyle(
                                                          color: appPrimary,
                                                          height: 1.4,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                );
                                              }

                                              if (m.isUser) {
                                                return Text(
                                                  m.text,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    height: 1.4,
                                                  ),
                                                );
                                              }

                                              // Если есть файл, показываем его
                                              if (m.filePath != null &&
                                                  m.filePath!.isNotEmpty) {
                                                // Проверяем тип файла
                                                final isImage =
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.png') ||
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.jpg') ||
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.jpeg');

                                                final isAudio =
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.mp3') ||
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.wav') ||
                                                    m.filePath!
                                                        .toLowerCase()
                                                        .endsWith('.m4a');

                                                if (isAudio) {
                                                  // Показываем встроенный аудио плеер
                                                  return _AudioPlayerWidget(
                                                    filePath: m.filePath!,
                                                  );
                                                }

                                                if (isImage) {
                                                  // Показываем изображение с loader
                                                  return _ImageWithLoader(
                                                    filePath: m.filePath!,
                                                  );
                                                }

                                                // PDF файл - показываем карточку
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 80,
                                                      child: _AnimatedBorderWidget(
                                                        isLoading: m.isLoading,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            try {
                                                              await OpenFilex.open(
                                                                m.filePath!,
                                                              );
                                                            } catch (e) {
                                                              if (!mounted) {
                                                                return;
                                                              }
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Не удалось открыть файл: $e',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  appSecondary
                                                                      .withOpacity(
                                                                        0.08,
                                                                      ),
                                                                  appSecondary
                                                                      .withOpacity(
                                                                        0.03,
                                                                      ),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  width: 54,
                                                                  height: 54,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: appSecondary
                                                                            .withOpacity(
                                                                              0.1,
                                                                            ),
                                                                        blurRadius:
                                                                            4,
                                                                        offset:
                                                                            Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        8,
                                                                      ),
                                                                  child: Image.asset(
                                                                    'assets/icons/pdf-icon.png',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Flexible(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        (m.text.isNotEmpty
                                                                                ? m.text
                                                                                : (m.filePath != null && m.filePath!.isNotEmpty
                                                                                    ? p.basename(m.filePath!)
                                                                                    : '')),
                                                                        style: TextStyle(
                                                                          color:
                                                                              appPrimary,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.touch_app,
                                                                            size:
                                                                                14,
                                                                            color: appSecondary.withOpacity(
                                                                              0.7,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            'Нажмите, чтобы открыть',
                                                                            style: TextStyle(
                                                                              color: appSecondary.withOpacity(
                                                                                0.7,
                                                                              ),
                                                                              fontSize: 12,
                                                                              height: 1.2,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  size: 16,
                                                                  color: appSecondary
                                                                      .withOpacity(
                                                                        0.5,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    InkWell(
                                                      onTap: () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: m.filePath!,
                                                          ),
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Путь скопирован: ${m.filePath!}',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: appPrimary
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.copy,
                                                              size: 16,
                                                              color: appPrimary,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              'Скопировать путь',
                                                              style: TextStyle(
                                                                color:
                                                                    appPrimary,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }

                                              // Проверяем длину текста для кнопок

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MarkdownBody(
                                                    data: m.text,
                                                    styleSheet: MarkdownStyleSheet(
                                                      p: TextStyle(
                                                        color: appPrimary,
                                                        height: 1.4,
                                                        fontSize: 14,
                                                      ),
                                                      h1: TextStyle(
                                                        color: appPrimary,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                      ),
                                                      h2: TextStyle(
                                                        color: appPrimary,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                      ),
                                                      h3: TextStyle(
                                                        color: appPrimary,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                      ),
                                                      h4: TextStyle(
                                                        color: appPrimary,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                      ),
                                                      strong: TextStyle(
                                                        color: appPrimary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      em: TextStyle(
                                                        color: appPrimary,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      listBullet: TextStyle(
                                                        color: appPrimary,
                                                        fontSize: 14,
                                                      ),
                                                      code: TextStyle(
                                                        backgroundColor:
                                                            appSecondary
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                        color: appPrimary,
                                                        fontFamily: 'monospace',
                                                      ),
                                                      codeblockDecoration:
                                                          BoxDecoration(
                                                            color: appSecondary
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                      codeblockPadding:
                                                          EdgeInsets.all(8),
                                                    ),
                                                  ),
                                                  // Кнопки для длинных сообщений
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Кнопки быстрого выбора
                                    if (m.quickOptions != null &&
                                        m.quickOptions!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ...m.quickOptions!.map((option) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                        aiChatViewModelProvider
                                                            .notifier,
                                                      )
                                                      .sendMessage(option);
                                                  // Скроллим вниз после отправки
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                        (_) => _scrollToBottom(
                                                          smooth: false,
                                                        ),
                                                      );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color: appAccentEnd,
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: appAccentEnd
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    option,
                                                    style: const TextStyle(
                                                      color: appPrimary,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          // Кнопка отмены
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                ref
                                                    .read(
                                                      aiChatViewModelProvider
                                                          .notifier,
                                                    )
                                                    .cancelPlanCreation();
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: appSecondary,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appSecondary
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'Отмена',
                                                  style: TextStyle(
                                                    color: appSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    // Действия вне пузыря для ответов бота
                                    if (!m.isUser &&
                                        !m.isLoading &&
                                        m.text.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Builder(
                                        builder: (_) {
                                          // Поиск кодовых блоков вида ```lang?\n...```
                                          final codeReg = RegExp(
                                            r"```[\w\-+]*\n([\s\S]*?)```",
                                            multiLine: true,
                                          );
                                          final matches = codeReg
                                              .allMatches(m.text)
                                              .toList();
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Кнопки копирования и поделиться
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    onPressed: () async {
                                                      await Clipboard.setData(
                                                        ClipboardData(
                                                          text: m.text,
                                                        ),
                                                      );
                                                      if (!mounted) return;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Ответ скопирован',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.copy,
                                                      size: 16,
                                                      color: appSecondary,
                                                    ),
                                                    label: const Text(''),
                                                  ),
                                                  const SizedBox(width: 4),

                                                  if (_isTestMessage(m) &&
                                                      (m.filePath == null ||
                                                          m
                                                              .filePath!
                                                              .isEmpty) &&
                                                      (m.quickOptions == null ||
                                                          m
                                                              .quickOptions!
                                                              .isEmpty))
                                                    InkWell(
                                                      onTap: () async {
                                                        await ref
                                                            .read(
                                                              aiChatViewModelProvider
                                                                  .notifier,
                                                            )
                                                            .createPdfFromText(
                                                              m.text,
                                                              title: 'Документ',
                                                            );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: appAccentEnd
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .picture_as_pdf,
                                                              size: 16,
                                                              color:
                                                                  appAccentEnd,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              'PDF',
                                                              style: TextStyle(
                                                                color:
                                                                    appAccentEnd,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              // Кнопки копирования кодовых блоков
                                              if (matches.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                for (
                                                  int idx = 0;
                                                  idx < matches.length;
                                                  idx++
                                                )
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      onPressed: () async {
                                                        final match =
                                                            matches[idx];
                                                        final code =
                                                            match.group(1) ??
                                                            '';
                                                        await Clipboard.setData(
                                                          ClipboardData(
                                                            text: code.trim(),
                                                          ),
                                                        );
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Код #${idx + 1} скопирован',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.code,
                                                        size: 16,
                                                      ),
                                                      label: Text(
                                                        'Скопировать код #${idx + 1}',
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick actions row - only show when chat is not empty
                  if (messages.isNotEmpty)
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        children: [
                          _QuickActionButton(
                            label: 'Создать план конспект',
                            icon: 'assets/icons/pdf-icon.png',
                            onTap: () async {
                              await ref
                                  .read(aiChatViewModelProvider.notifier)
                                  .startPlanCreation();
                              // Скроллим вниз после запуска
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToBottom(smooth: false),
                              );
                            },
                          ),
                          _QuickActionButton(
                            label: 'Генерация картинки',
                            icon: 'assets/icons/image-icon.png',
                            onTap: () async {
                              await ref
                                  .read(aiChatViewModelProvider.notifier)
                                  .startImageGeneration();
                              // Скроллим вниз после запуска
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToBottom(smooth: false),
                              );
                            },
                          ),
                          _QuickActionButton(
                            label: 'Генерация аудио',
                            icon:'',
                            onTap: () async {
                              await ref
                                  .read(aiChatViewModelProvider.notifier)
                                  .startAudioGeneration();
                              // Скроллим вниз после запуска
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToBottom(smooth: false),
                              );
                            },
                          ),
                          _QuickActionButton(
                            label: 'Анализ картинки',
                            icon: '',
                            onTap: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1600,
                                maxHeight: 1600,
                                imageQuality: 85,
                              );
                              if (picked == null) return;
                              final bytes = await picked.readAsBytes();
                              await ref
                                  .read(aiChatViewModelProvider.notifier)
                                  .sendImageForAnalysis(bytes);
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToBottom(),
                              );
                            },
                          ),
                          _QuickActionButton(
                            label: 'Короткий ответ',
                            icon: '',
                            onTap: () {
                              _controller.text =
                                  'Дайте краткий ответ, 3–4 предложения.';
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Input container
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: appPrimary.withOpacity(0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1600,
                                    maxHeight: 1600,
                                    imageQuality: 85,
                                  );
                                  if (picked == null) return;
                                  final bytes = await picked.readAsBytes();
                                  await ref
                                      .read(aiChatViewModelProvider.notifier)
                                      .sendImageForAnalysis(bytes);
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _scrollToBottom(),
                                  );
                                },
                                icon: Icon(Icons.add, color: appSecondary),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.montserrat().fontFamily,                                    fontWeight: FontWeight.w400,
                                      fontSize: 14
                                  ),
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Спросите меня что-нибудь...',
                                    hintStyle: TextStyle(
                                      fontFamily: GoogleFonts.montserrat().fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            _scrollToBottom(smooth: false);
                                          }
                                        });
                                  });
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Введите сообщение или вставьте изображение',
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  _controller.clear();
                                  await ref
                                      .read(aiChatViewModelProvider.notifier)
                                      .sendMessage(text);
                                  // Тройной postFrameCallback для полного рендеринга
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (mounted &&
                                                    _scrollController
                                                        .hasClients) {
                                                  final max = _scrollController
                                                      .position
                                                      .maxScrollExtent;
                                                  _scrollController.jumpTo(max);
                                                }
                                              });
                                        });
                                  });
                                },
                                icon: Image.asset('assets/icons/send-fill-icon.png', width: 28, height: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(WidgetRef ref) {
    return Container(
      color: appBackground,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Анимированная картинка приветствия (ai_chat.gif)
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     shape: BoxShape.circle,
              //     boxShadow: [
              //       BoxShadow(
              //         color: appPrimary.withOpacity(0.08),
              //         blurRadius: 20,
              //         offset: const Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Semantics(
              //     label: 'AI chat animation',
              //     child: Image.asset(
              //       'assets/animations/ai_logo.gif',
              //       width: 140,
              //       height: 140,
              //       fit: BoxFit.contain,
              //     ),
              //   ),
              // ),
              // Приветственный текст
              Text(
                'С чего начнем?',
                style: TextStyle(
                  color: appPrimary,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Выберите действие или задайте вопрос',
                style: TextStyle(
                  fontFamily:  GoogleFonts.roboto().fontFamily,
                  color: appSecondary.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Кнопки быстрых действий — в одну строку с горизонтальной прокруткой
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _WelcomeActionCard(
                    title: 'Создать план-конспект',
                    icon: 'assets/icons/pdf-icon.png',
                    description: 'Создать план урока',
                    onTap: () async {
                      await ref
                          .read(aiChatViewModelProvider.notifier)
                          .startPlanCreation();
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(smooth: false),
                      );
                    },
                  ),
                  _WelcomeActionCard(
                    icon: 'assets/icons/image-icon.png',
                    title: 'Генерация картинки',
                    description: 'Создать изображение',
                    onTap: () async {
                      await ref
                          .read(aiChatViewModelProvider.notifier)
                          .startImageGeneration();
                    },
                  ),
                  if (!_showMoreActions)
                    _WelcomeActionCard(
                      icon: '',
                      title: 'Еще',
                      description: 'Показать дополнительные действия',
                      onTap: () {
                        setState(() {
                          _showMoreActions = true;
                        });
                      },
                    )
                  else ...[
                    _WelcomeActionCard(
                      icon: 'assets/icons/pdf-icon.png',
                      title: 'Думай',
                      description: 'Загрузить фото',
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (img != null) {
                          final bytes = await img.readAsBytes();
                          await ref
                              .read(aiChatViewModelProvider.notifier)
                              .sendImageForAnalysis(bytes);
                        }
                      },
                    ),
                    _WelcomeActionCard(
                      icon: 'assets/icons/pdf-icon.png',
                      title: 'Анализ по ссылке',
                      description: 'Вставить URL изображения',
                      onTap: () async {
                        final ctrl = TextEditingController();
                        final url = await showDialog<String>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('URL изображения'),
                            content: TextField(controller: ctrl),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, ctrl.text),
                                child: const Text('Анализировать'),
                              ),
                            ],
                          ),
                        );
                        if (url != null && url.isNotEmpty) {
                          await ref
                              .read(aiChatViewModelProvider.notifier)
                              .sendImageUrlForAnalysis(url);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryStreamProvider);
    final historyService = ref.watch(chatHistoryServiceProvider);

    return Drawer(
      backgroundColor: appBackground,
      child: AnimatedBuilder(
        animation: _drawerSlideAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _drawerSlideAnimation,
            child: SafeArea(
              child: Column(
          children: [
            // Заголовок
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: appPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:SvgPicture.asset(
                                'assets/icons/history-icon.svg',
                                width: 25,
                                height: 25,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'История',
                          style: TextStyle(
                            color: appPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: appSecondary,
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Закрыть',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Последние 10 чатов',
                    style: TextStyle(
                      color: appSecondary.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка "Библиотека"
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImageLibraryPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [appAccentStart, appAccentEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.collections_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Библиотека изображений',
                          style: TextStyle(
                            color: appPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: appSecondary.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Список чатов
            Expanded(
              child: historyAsync.when(
                data: (chats) {
                  final recentChats = chats.take(10).toList();

                  if (recentChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: appSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Нет истории чатов',
                            style: TextStyle(
                              color: appSecondary.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Начните новый разговор',
                            style: TextStyle(
                              color: appSecondary.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: recentChats.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                      indent: 68,
                    ),
                    itemBuilder: (context, index) {
                      final chat = recentChats[index];
                      final dateFormat = DateFormat('dd.MM HH:mm');
                      final now = DateTime.now();
                      final difference = now.difference(chat.updatedAt);
                      final isActive =
                          chat.id ==
                          ref.watch(aiChatViewModelProvider).currentChatId;

                      String timeAgo;
                      if (difference.inMinutes < 1) {
                        timeAgo = 'только что';
                      } else if (difference.inMinutes < 60) {
                        timeAgo = '${difference.inMinutes} мин назад';
                      } else if (difference.inHours < 24) {
                        timeAgo = '${difference.inHours} ч назад';
                      } else if (difference.inDays < 7) {
                        timeAgo = '${difference.inDays} дн назад';
                      } else {
                        timeAgo = dateFormat.format(chat.updatedAt);
                      }

                      return Dismissible(
                        key: Key(chat.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.shade50,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade400,
                            size: 24,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Удалить чат?'),
                                  content: const Text(
                                    'Это действие нельзя отменить.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (direction) async {
                          await historyService.deleteChat(chat.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Чат удален'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await ref
                                  .read(aiChatViewModelProvider.notifier)
                                  .loadChat(chat.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: isActive
                                  ? BoxDecoration(
                                      color: appAccentEnd.withOpacity(0.08),
                                      border: const Border(
                                        left: BorderSide(
                                          color: appAccentEnd,
                                          width: 3,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Иконка
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? appAccentEnd.withOpacity(0.15)
                                          : appPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? appAccentEnd.withOpacity(0.3)
                                            : appPrimary.withOpacity(0.1),
                                        width: isActive ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Icon(
                                      isActive
                                          ? Icons.chat_bubble_rounded
                                          : Icons.chat_bubble_outline_rounded,
                                      color: isActive
                                          ? appAccentEnd
                                          : appPrimary.withOpacity(0.7),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Контент
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat.title,
                                          style: TextStyle(
                                            color: isActive
                                                ? appAccentEnd
                                                : appPrimary,
                                            fontSize: 14,
                                            fontWeight: isActive
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color: appSecondary.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              timeAgo,
                                              style: TextStyle(
                                                color: appSecondary.withOpacity(
                                                  0.6,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.message_outlined,
                                              size: 12,
                                              color: appSecondary.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${chat.messages.length}',
                                              style: TextStyle(
                                                color: appSecondary.withOpacity(
                                                  0.6,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Индикатор активного чата
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: appAccentEnd,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: appSecondary.withOpacity(0.3),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ошибка загрузки',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: appSecondary.withOpacity(0.7),
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
      ),
          );
        },
      ),
    );
  }
}

/// Виджет изображения с loader
class _ImageWithLoader extends StatefulWidget {
  final String filePath;

  const _ImageWithLoader({required this.filePath});

  @override
  State<_ImageWithLoader> createState() => _ImageWithLoaderState();
}

class _ImageWithLoaderState extends State<_ImageWithLoader> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Открыть изображение в полноэкранном режиме
        showDialog(
          context: context,
          builder: (_) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: InteractiveViewer(
                child: Image.file(File(widget.filePath), fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Изображение
            Image.file(
              File(widget.filePath),
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _isLoading = false);
                  });
                  return child;
                }
                if (frame != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _isLoading = false);
                  });
                }
                return child;
              },
            ),
            // Loader поверх изображения
            if (_isLoading)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appAccentStart.withOpacity(0.15),
                      appAccentEnd.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: appAccentEnd,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Загрузка изображения...',
                        style: TextStyle(
                          color: appPrimary.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Виджет с анимированным border для loading состояния
class _AnimatedBorderWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const _AnimatedBorderWidget({required this.child, required this.isLoading});

  @override
  State<_AnimatedBorderWidget> createState() => _AnimatedBorderWidgetState();
}

class _AnimatedBorderWidgetState extends State<_AnimatedBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_AnimatedBorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      // Обычный border когда не загружается
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1.5, color: appSecondary.withOpacity(0.2)),
        ),
        child: widget.child,
      );
    }

    // Анимированный градиентный border при загрузке
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [appAccentStart, appAccentEnd, appAccentStart],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2), // Толщина border
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Виджет аудио плеера (открывает в системном плеере)
class _AudioPlayerWidget extends StatelessWidget {
  final String filePath;

  const _AudioPlayerWidget({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await OpenFilex.open(filePath);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось открыть аудио: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appAccentStart.withOpacity(0.1),
              appAccentEnd.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appAccentEnd.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appAccentEnd,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Аудио сообщение',
                    style: TextStyle(
                      color: appPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Нажмите для воспроизведения',
                    style: TextStyle(
                      color: appPrimary.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: appAccentEnd.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Анимированный индикатор печати
class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          'ИИ печатает${'.' * (1 + (_animation.value * 2).round())}',
          style: TextStyle(
            color: appPrimary,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
