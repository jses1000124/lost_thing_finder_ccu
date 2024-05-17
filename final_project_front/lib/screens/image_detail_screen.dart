import 'package:flutter/material.dart';

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
        clipBehavior: Clip.none, // 允許圖片超出邊界
        child: Center(child: Image.network(imageURL)),
      ),
    );
  }
}
