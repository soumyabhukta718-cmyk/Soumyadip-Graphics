import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
  });

  final ChatMessage message;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final bool user = message.isUser;
    final Color bubbleColor = user
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color textColor = user
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (message.imagePath != null && message.imagePath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.image_outlined, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Image attached',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  DateFormat('hh:mm a').format(message.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.75),
                      ),
                ),
                if (!user) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      message.isOffline ? 'Offline' : 'Online',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor),
                    ),
                  ),
                ],
                if (!user && onSpeak != null) ...<Widget>[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onSpeak,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.volume_up_rounded, color: textColor, size: 18),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
