import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/screens/lost_thing_detail_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LostThingItem extends StatelessWidget {
  const LostThingItem(this.lostThing, {super.key});

  final LostThing lostThing;

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
                child: lostThing.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: lostThing.imageUrl,
                        placeholder: (context, url) => const SizedBox(
                          height: 80,
                          width: 80,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        cacheKey: lostThing.imageUrl, // 使用圖片URL作為緩存鍵
                        // 可選項: 配置緩存選項，如最大緩存大小等
                        cacheManager: CacheManager(
                          Config(
                            'customCacheKey',
                            stalePeriod: const Duration(days: 2), // 7天內不會重新加載
                            maxNrOfCacheObjects: 100, // 最大緩存圖片數量
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 80,
                        width: 80,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lostThing.lostThingName,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '位置: ${lostThing.location}',
                      style: const TextStyle(fontSize: 16),
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
