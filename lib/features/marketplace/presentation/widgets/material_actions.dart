import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../../domain/entities/educational_material.dart';

class MaterialActions extends StatelessWidget {
  final EducationalMaterial material;
  final bool isPurchased;
  final VoidCallback onPurchase;
  final VoidCallback onDownload;

  const MaterialActions({
    super.key,
    required this.material,
    required this.isPurchased,
    required this.onPurchase,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPurchased)
          _buildDownloadButton()
        else
          _buildPurchaseButton(),
        const SizedBox(height: 8),
        _buildSecondaryActions(),
      ],
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: onPurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: appAccentEnd,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              material.isFree ? Icons.download : Icons.shopping_cart,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              material.isFree ? 'Скачать' : 'Купить',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: onDownload,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 20),
            const SizedBox(width: 8),
            Text(
              'Скачать',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.favorite_border,
          label: 'В избранное',
          onTap: () {
            // TODO: Add to favorites
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.share,
          label: 'Поделиться',
          onTap: () {
            // TODO: Share material
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: appSecondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: appSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: appSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
