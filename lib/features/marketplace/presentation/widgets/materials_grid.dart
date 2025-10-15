import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';
import 'material_card.dart';

class MaterialsGrid extends StatelessWidget {
  final List<EducationalMaterial> materials;
  final bool isLoading;
  final bool hasMore;
  final Function(EducationalMaterial) onMaterialTap;
  final Function(EducationalMaterial) onFavoriteTap;

  const MaterialsGrid({
    super.key,
    required this.materials,
    required this.isLoading,
    required this.hasMore,
    required this.onMaterialTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && materials.isEmpty) {
      return const _LoadingGrid();
    }

    if (materials.isEmpty) {
      return const _EmptyGrid();
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < materials.length) {
              final material = materials[index];
              return MaterialCard(
                material: material,
                onTap: () => onMaterialTap(material),
                onFavoriteTap: () => onFavoriteTap(material),
              );
            } else if (isLoading) {
              return const _LoadingCard();
            } else {
              return null;
            }
          },
          childCount: materials.length + (isLoading ? 2 : 0),
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _LoadingCard(),
          childCount: 6,
        ),
      ),
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  const _EmptyGrid();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appPrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: appSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Материалы не найдены',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить фильтры или поисковый запрос',
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
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thumbnail placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: appSecondary.withOpacity(0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: appSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 18,
                        width: 50,
                        decoration: BoxDecoration(
                          color: appSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 18,
                        width: 40,
                        decoration: BoxDecoration(
                          color: appSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 14,
                        width: 50,
                        decoration: BoxDecoration(
                          color: appSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 14,
                        width: 40,
                        decoration: BoxDecoration(
                          color: appSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
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
}
