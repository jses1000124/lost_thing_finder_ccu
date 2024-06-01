import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/screens/lost_thing_detail_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LostThingItem extends StatelessWidget {
  const LostThingItem(this.lostThing, {super.key});

  final LostThing lostThing;

  Future<bool> _isImageCached(String url) async {
    final fileInfo = await DefaultCacheManager().getFileFromCache(url);
    return fileInfo != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: InkWell(
          splashColor: const Color.fromARGB(0, 255, 255, 255),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LostThingDetailScreen(
                      lostThings: lostThing,
                    )));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color.fromARGB(0, 0, 0, 0),
                child: lostThing.imageUrl != ''
                    ? FutureBuilder<bool>(
                        future: _isImageCached(lostThing.imageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error);
                          } else if (snapshot.hasData &&
                              snapshot.data == true) {
                            // 如果图片已缓存，直接显示图片，不使用占位符
                            return CachedNetworkImage(
                              imageUrl: lostThing.imageUrl,
                              cacheKey: lostThing.imageUrl,
                              cacheManager: CacheManager(
                                Config(
                                  'customCacheKey',
                                  stalePeriod: const Duration(days: 4),
                                  maxNrOfCacheObjects: 100,
                                ),
                              ),
                              height: 80,
                              width: 80,
                            );
                          } else {
                            // 如果图片未缓存，显示占位符
                            return CachedNetworkImage(
                              imageUrl: lostThing.imageUrl,
                              placeholder: (context, url) => const SizedBox(
                                height: 80,
                                width: 80,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              cacheKey: lostThing.imageUrl,
                              cacheManager: CacheManager(
                                Config(
                                  'customCacheKey',
                                  stalePeriod: const Duration(days: 2),
                                  maxNrOfCacheObjects: 100,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              height: 80,
                              width: 80,
                            );
                          }
                        },
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lostThing.lostThingName,
                      style: const TextStyle(
                          fontSize: 20, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    Text(
                      '位置: ${lostThing.location}',
                      style: const TextStyle(
                          fontSize: 16, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    Text(
                      '日期: ${lostThing.formattedDate}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
