import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';

class ZipgradeScanPage extends ConsumerStatefulWidget {
  const ZipgradeScanPage({super.key});

  @override
  ConsumerState<ZipgradeScanPage> createState() => _ZipgradeScanPageState();
}

class _ZipgradeScanPageState extends ConsumerState<ZipgradeScanPage> {
  CameraController? _controller;
  late final TextRecognizer _textRecognizer;
  bool _isBusy = false;
  String? _lastResult;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      final controller = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Камера недоступна: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _scanOnce() async {
    final controller = _controller;
    if (controller == null || _isBusy || !controller.value.isInitialized) return;
    setState(() => _isBusy = true);
    try {
      final file = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final recognized = await _textRecognizer.processImage(inputImage);
      final buffer = StringBuffer();
      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }
      final text = buffer.toString();
      // TODO: парсинг ответов из текста и маппинг к вопросам (упрощённо сохраняем результат)
      setState(() => _lastResult = text.isEmpty ? 'Текст не распознан' : text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сканирования: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZipGrade — сканирование', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: appPrimary,
        elevation: 0,
      ),
      backgroundColor: appBackground,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: _controller?.value.isInitialized == true
                  ? CameraPreview(_controller!)
                  : const Center(child: CircularProgressIndicator(color: appAccentEnd)),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isBusy ? null : _scanOnce,
                        icon: const Icon(Icons.document_scanner),
                        label: const Text('Сканировать бланк'),
                        style: ElevatedButton.styleFrom(backgroundColor: appAccentEnd),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Распознанный текст:', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: appPrimary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: appBackground, borderRadius: BorderRadius.circular(8)),
                  child: Text(_lastResult ?? '—', style: GoogleFonts.montserrat(color: appSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


