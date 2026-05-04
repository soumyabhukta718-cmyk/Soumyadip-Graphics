import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/study_data_provider.dart';
import '../widgets/gradient_card.dart';
import '../widgets/section_title.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _joinController = TextEditingController();
  String? _roomCode;

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final StudyDataProvider study = context.watch<StudyDataProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Group Study Connect', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Create or join a basic code-based room now. Video call and live collaboration can plug in later.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _roomCode = _generateRoomCode());
                      },
                      icon: const Icon(Icons.meeting_room_rounded),
                      label: const Text('Create Room'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (_joinController.text.trim().isEmpty) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Room ${_joinController.text.trim().toUpperCase()} placeholder opened.')),
                        );
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Join Room'),
                    ),
                  ],
                ),
                if (_roomCode != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text('Your room code: $_roomCode', style: Theme.of(context).textTheme.titleMedium),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _joinController,
            decoration: const InputDecoration(
              labelText: 'Enter room code',
              prefixIcon: Icon(Icons.password_rounded),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Sync & Collaboration Status',
            subtitle: 'Offline-first today, cloud-ready for tomorrow',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cloud sync: ${settings.cloudSyncEnabled ? 'On' : 'Off'}'),
                const SizedBox(height: 8),
                Text(study.syncStatus),
                const SizedBox(height: 12),
                Text(
                  'Future-ready modules: shared whiteboard, live voice room, peer leaderboard, and mentor calls.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateRoomCode() {
    const String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final Random random = Random();
    return List<String>.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
