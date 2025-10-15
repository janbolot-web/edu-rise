import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';

class ImageLibraryPage extends ConsumerStatefulWidget {
  const ImageLibraryPage({super.key});

  @override
  ConsumerState<ImageLibraryPage> createState() => _ImageLibraryPageState();
}

class _ImageLibraryPageState extends ConsumerState<ImageLibraryPage> {
  List<FileSystemEntity> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _loading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      final imageFiles = files.where((file) {
        final path = file.path.toLowerCase();
        return path.endsWith('.png') ||
            path.endsWith('.jpg') ||
            path.endsWith('.jpeg');
      }).toList();

      imageFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      setState(() {
        _images = imageFiles;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('Библиотека изображений'),
        backgroundColor: Colors.white,
        foregroundColor: appPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: appSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет сохраненных изображений',
                        style: TextStyle(
                          color: appSecondary.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Создайте изображение через AI чат',
                        style: TextStyle(
                          color: appSecondary.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final file = _images[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Dialog(
                              backgroundColor: Colors.black87,
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    child: Image.file(
                                      File(file.path),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Удалить изображение?'),
                            content:
                                const Text('Это действие нельзя отменить.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await file.delete();
                            await _loadImages();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Изображение удалено')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка удаления: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: appPrimary.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
