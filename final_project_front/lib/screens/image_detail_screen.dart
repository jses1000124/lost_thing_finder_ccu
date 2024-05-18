import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imageURL;

  const ImageDetailScreen({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.1,
        maxScale: 10.0,
        clipBehavior: Clip.none, // Allow image to exceed boundary
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imageURL,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
            cacheKey: imageURL, // 使用圖片URL作為緩存鍵
            cacheManager: CacheManager(Config(
              'customCacheKey',
              stalePeriod: const Duration(days: 2), // 7天內不會重新加載
              maxNrOfCacheObjects: 100, // 最大緩存圖片數量
            )),
          ),
        ),
      ),
    );
  }
}
