import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // Automatically convert to https if needed
    String safeUrl =
        imageUrl.startsWith('http://')
            ? imageUrl.replaceFirst('http://', 'https://')
            : imageUrl;

    return Image.network(
      safeUrl,
      width: width,
      height: height,
      fit: fit,
      headers: const {'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp)'},
      errorBuilder: (context, error, stackTrace) {
        // Fallback widget when image fails to load
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value:
                  progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                      : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}
