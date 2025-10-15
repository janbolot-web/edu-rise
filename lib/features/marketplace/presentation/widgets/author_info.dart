import 'package:flutter/material.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edurise/core/theme/app_colors.dart';

class AuthorInfo extends StatelessWidget {
  final String authorName;
  final String authorAvatar;
  final double rating;
  final int reviewCount;

  const AuthorInfo({
    super.key,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: SafeNetworkImage(
              src: authorAvatar,
              fallbackAsset: 'assets/images/author.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authorName,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: appPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($reviewCount отзывов)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
           
          },
          child: Text(
            'Профиль',
            style: GoogleFonts.montserrat(
              color: appAccentEnd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
