import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/screens/image_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.imageURL,
  }) : isFirstInSequence = true;

  // Create a message bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.imageURL,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  final String? userImage;

  // Username of the user.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  final String imageURL;

  // Show the user context menu when the user image is tapped.
  void _showUserContextMenu() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/images/avatar_$userImage.png'),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
              child: GestureDetector(
                onTap: () {
                  _showUserContextMenu();
                },
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (imageURL.isNotEmpty)
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return ImageDetailScreen(imageURL: imageURL);
                        }));
                      },
                      child: Container(
                        width: 200, // 設定容器的寬度
                        height: 200,
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            topRight: isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            topRight: isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageURL,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit
                                .cover, // Use BoxFit.cover to maintain the image's aspect ratio
                            cacheKey: imageURL, // 使用圖片URL作為緩存鍵
                            cacheManager: CacheManager(Config(
                              'customCacheKey',
                              stalePeriod: const Duration(days: 2), // 7天內不會重新加載
                              maxNrOfCacheObjects: 100, // 最大緩存圖片數量
                            )),
                          ),
                        ),
                      ),
                    ),
                  if (imageURL.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.grey[300]
                            : theme.colorScheme.secondary.withAlpha(200),
                        borderRadius: BorderRadius.only(
                          topLeft: !isMe && isFirstInSequence
                              ? Radius.zero
                              : const Radius.circular(12),
                          topRight: isMe && isFirstInSequence
                              ? Radius.zero
                              : const Radius.circular(12),
                          bottomLeft: const Radius.circular(12),
                          bottomRight: const Radius.circular(12),
                        ),
                      ),
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 12,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          height: 1.3,
                          color: isMe
                              ? Colors.black87
                              : theme.colorScheme.onSecondary,
                        ),
                        softWrap: true,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
