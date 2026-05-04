import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/tutor_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/empty_state_card.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TutorProvider tutor = context.watch<TutorProvider>();
    final SettingsProvider settings = context.watch<SettingsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.smart_toy_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Shindhu Tutor', style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        settings.onlineTutorEnabled && settings.hasOnlineConfig
                            ? 'Hybrid mode: online + offline fallback'
                            : 'Offline-first mode active',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<TutorProvider>().clearChat(),
                  icon: const Icon(Icons.delete_sweep_rounded),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: tutor.messages.isEmpty
                ? const EmptyStateCard(
                    title: 'Ask a question',
                    message: 'Type a question or attach an image for guided solving.',
                    icon: Icons.question_answer_rounded,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: tutor.messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final message = tutor.messages[index];
                      return ChatBubble(
                        message: message,
                        onSpeak: message.isUser ? null : () => context.read<TutorProvider>().speak(message),
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: <Widget>[
                if (tutor.attachedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.image_rounded),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Image selected for question solving')),
                        IconButton(
                          onPressed: () => context.read<TutorProvider>().attachImage(null),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null && context.mounted) {
                          context.read<TutorProvider>().attachImage(image.path);
                        }
                      },
                      icon: const Icon(Icons.image_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ask in English or Bengali...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: tutor.isSending
                          ? null
                          : () async {
                              final String value = _controller.text;
                              _controller.clear();
                              await context.read<TutorProvider>().sendMessage(
                                    text: value,
                                    settings: settings,
                                  );
                            },
                      child: tutor.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
