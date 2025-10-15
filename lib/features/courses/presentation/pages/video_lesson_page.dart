import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pod_player/pod_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edurise/core/theme/app_colors.dart';

class VideoLessonPage extends StatefulWidget {
  final String title;
  final String youtubeUrl;
  final String description;
  final List<String> resources;
  final List<String> tests;

  const VideoLessonPage({
    super.key,
    required this.title,
    required this.youtubeUrl,
    required this.description,
    this.resources = const [],
    this.tests = const [],
  });

  @override
  State<VideoLessonPage> createState() => _VideoLessonPageState();
}

class _VideoLessonPageState extends State<VideoLessonPage> {
  PodPlayerController? _controller;
  bool _isFullScreen = false;
  String? _videoId;
  WebViewController? _webController;

  @override
  void initState() {
    super.initState();
    final videoId = _getYoutubeVideoId(widget.youtubeUrl);
    _videoId = videoId;
    if (videoId != null) {
      // Use WebView embed for YouTube links (avoid youtube_player_iframe dependency)
      final embedUrl = Uri.parse('https://www.youtube.com/embed/$videoId?autoplay=1&controls=1');
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(embedUrl);
    } else {
      // Non-YouTube: try PodPlayer for direct media
      try {
        _controller = PodPlayerController(
          playVideoFrom: PlayVideoFrom.network(widget.youtubeUrl),
          podPlayerConfig: const PodPlayerConfig(
            autoPlay: true,
            isLooping: false,
            videoQualityPriority: [720, 480, 360],
          ),
        )..initialise();
      } catch (e) {
        // If PodPlayer can't initialize, fallback to WebView
        final embedUrl = Uri.parse(widget.youtubeUrl);
        _webController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(embedUrl);
      }
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // No youtube_player_iframe controller — use WebView for YouTube embeds.

  String? _getYoutubeVideoId(String url) {
    final regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  void dispose() {
    try {
      _controller?.dispose();
    } catch (_) {}
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: appPrimary,
              title: Text(
                widget.title,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: (
                // If this is a YouTube URL (videoId parsed) - show WebView embed
                _videoId != null
                    ? (_webController != null
                        ? ClipRect(
                            child: SizedBox.expand(
                              child: WebViewWidget(controller: _webController!),
                            ),
                          )
                        : const Center(child: Text('Видео недоступно')))
                    // Non-YouTube: try PodPlayer, else WebView or unavailable
                    : (_controller != null
                        ? PodVideoPlayer(
                            controller: _controller!,
                            onToggleFullScreen: (isFullScreen) async {
                              setState(() => _isFullScreen = isFullScreen);
                            },
                            videoAspectRatio: 16 / 9,
                            matchFrameAspectRatioToVideo: true,
                          )
                        : (_webController != null
                            ? ClipRect(
                                child: SizedBox.expand(
                                  child: WebViewWidget(controller: _webController!),
                                ),
                              )
                            : const Center(child: Text('Видео недоступно')))))
          ),
          if (!_isFullScreen) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок урока
                    Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: appPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Описание урока
                    Text(
                      widget.description,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: appSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Файлы урока / материалы
                    if (widget.resources.isNotEmpty) ...[
                      Text(
                        'Файлы урока',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: appPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.resources.map((res) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    res,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: appPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final uri = Uri.tryParse(res);
                                    if (uri != null && await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appAccentEnd,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Открыть'),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Тесты
                    if (widget.tests.isNotEmpty) ...[
                      Text(
                        'Тесты',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: appPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.tests.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: appPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: запустить тестовую страницу/встроенный тест
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Пройти'),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
