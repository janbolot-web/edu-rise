import 'package:flutter/material.dart';
import 'dart:io';

class SafeNetworkImage extends StatelessWidget {
  final String? src;
  final String fallbackAsset;
  final BoxFit? fit;
  final double? width;
  final double? height;
  const SafeNetworkImage({
    super.key,
    required this.src,
    required this.fallbackAsset,
    this.fit,
    this.width,
    this.height,
  });

  bool _isValidHttpUrl(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    try {
      final uri = Uri.tryParse(s);
      if (uri == null) return false;
  return (uri.scheme == 'http' || uri.scheme == 'https') && (uri.host.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidHttpUrl(src)) {
      return Image.network(
        src!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (c, e, st) => Image.asset(
          fallbackAsset,
          fit: fit,
          width: width,
          height: height,
        ),
      );
    }
    // Support local file paths from image_picker or app storage
    if (src != null && src!.isNotEmpty) {
      final uri = Uri.tryParse(src!);
      final isFileScheme = uri?.scheme == 'file';
      final isAbsolutePath = uri?.scheme.isEmpty == true && src!.startsWith('/');
      if (isFileScheme || isAbsolutePath) {
        final file = isFileScheme ? File(uri!.toFilePath()) : File(src!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (c, e, st) => Image.asset(
              fallbackAsset,
              fit: fit,
              width: width,
              height: height,
            ),
          );
        }
      }
    }
    return Image.asset(
      fallbackAsset,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
