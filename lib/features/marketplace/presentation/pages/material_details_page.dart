import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';
import '../widgets/material_preview.dart';
import '../widgets/review_section.dart';
import '../widgets/author_info.dart';
import '../widgets/material_actions.dart';
import '../viewmodels/material_details_viewmodel.dart';
import '../widgets/material_card.dart';

class MaterialDetailsPage extends ConsumerStatefulWidget {
  final String materialId;

  const MaterialDetailsPage({
    super.key,
    required this.materialId,
  });

  @override
  ConsumerState<MaterialDetailsPage> createState() => _MaterialDetailsPageState();
}

class _MaterialDetailsPageState extends ConsumerState<MaterialDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialAsync = ref.watch(materialDetailsProvider(widget.materialId));
    
    return materialAsync.when(
      data: (material) => _buildContent(material),
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: appAccentEnd),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Материал не найден',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(EducationalMaterial material) {
    return Scaffold(
      backgroundColor: appBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: MaterialPreview(
                material: material,
                onPlay: () {
                  // TODO: Play preview
                },
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Share material
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and basic info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: appPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Author info
                        AuthorInfo(
                          authorName: material.authorName,
                          authorAvatar: material.authorAvatar,
                          rating: material.rating,
                          reviewCount: material.reviewCount,
                        ),
                        const SizedBox(height: 16),
                        
                        // Price and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.isFree ? 'Бесплатно' : '${material.price.toStringAsFixed(0)} ₽',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: material.isFree ? Colors.green : appAccentEnd,
                                    ),
                                  ),
                                  if (!material.isFree)
                                    Text(
                                      'Скачиваний: ${material.downloads}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: appSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: MaterialActions(
                                material: material,
                                isPurchased: _isPurchased,
                                onPurchase: () {
                                  setState(() {
                                    _isPurchased = true;
                                  });
                                },
                                onDownload: () {
                                  // TODO: Handle download
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: appPrimary,
                      unselectedLabelColor: appSecondary,
                      indicatorColor: appAccentEnd,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Описание'),
                        Tab(text: 'Отзывы'),
                        Tab(text: 'Похожие'),
                      ],
                    ),
                  ),

                  // Tab content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDescriptionTab(material),
                        _buildReviewsTab(material),
                        _buildSimilarTab(material),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(EducationalMaterial material) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Описание',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            material.description,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: appPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Learning objectives
          Text(
            'Цели обучения',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...material.learningObjectives.map((objective) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: appAccentEnd,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: appPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),
          
          // Material info
          _buildInfoSection(material),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(EducationalMaterial material) {
    return ReviewSection(materialId: material.id);
  }

  Widget _buildSimilarTab(EducationalMaterial material) {
    final similarAsync = ref.watch(similarMaterialsProvider(material.subject));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Похожие материалы',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: appPrimary,
            ),
          ),
          const SizedBox(height: 16),
          similarAsync.when(
            data: (similarMaterials) {
              if (similarMaterials.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('Похожих материалов пока нет'),
                  ),
                );
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: similarMaterials.length,
                itemBuilder: (context, index) {
                  return MaterialCard(
                    material: similarMaterials[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialDetailsPage(
                            materialId: similarMaterials[index].id,
                          ),
                        ),
                      );
                    },
                    onFavoriteTap: () {},
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const Center(child: Text('Ошибка загрузки')),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(EducationalMaterial material) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Предмет', material.subject),
          _buildInfoRow('Класс', material.grade),
          _buildInfoRow('Тип', _getMaterialTypeText(material.type)),
          _buildInfoRow('Сложность', _getDifficultyText(material.difficulty)),
          _buildInfoRow('Время изучения', '${material.estimatedTime} мин'),
          _buildInfoRow('Размер файла', _formatFileSize(material.fileSize)),
          _buildInfoRow('Формат', material.fileFormat.toUpperCase()),
          _buildInfoRow('Язык', material.language),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMaterialTypeText(MaterialType type) {
    switch (type) {
      case MaterialType.presentation:
        return 'Презентация';
      case MaterialType.test:
        return 'Тест';
      case MaterialType.notes:
        return 'Конспект';
      case MaterialType.worksheet:
        return 'Рабочий лист';
      case MaterialType.lessonPlan:
        return 'План урока';
      case MaterialType.video:
        return 'Видео';
      case MaterialType.audio:
        return 'Аудио';
      case MaterialType.interactive:
        return 'Интерактив';
    }
  }

  String _getDifficultyText(MaterialDifficulty difficulty) {
    switch (difficulty) {
      case MaterialDifficulty.beginner:
        return 'Начальный';
      case MaterialDifficulty.intermediate:
        return 'Средний';
      case MaterialDifficulty.advanced:
        return 'Продвинутый';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  // Mock data for now
  EducationalMaterial _getMockMaterial() {
    return EducationalMaterial(
      id: '1',
      title: 'Презентация по алгебре: Квадратные уравнения',
      description: 'Подробная презентация по решению квадратных уравнений с примерами и упражнениями для 8-9 классов.',
      authorId: 'author1',
      authorName: 'Анна Петрова',
      authorAvatar: 'https://example.com/avatar.jpg',
      type: MaterialType.presentation,
      subject: 'Математика',
      grade: '8 класс',
      price: 299.0,
      currency: 'RUB',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      fileUrls: const ['https://example.com/file.pdf'],
      downloads: 1247,
      rating: 4.8,
      reviewCount: 156,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: true,
      tags: const ['алгебра', 'уравнения', '8 класс'],
      language: 'ru',
      fileSize: 2500000,
      fileFormat: 'pdf',
      difficulty: MaterialDifficulty.intermediate,
      estimatedTime: 45,
      previewText: 'Введение в квадратные уравнения...',
      learningObjectives: const [
        'Понять определение квадратного уравнения',
        'Научиться решать квадратные уравнения',
        'Применять формулы для решения задач',
      ],
      isFree: false,
      isFeatured: true,
      viewCount: 3421,
    );
  }
}
