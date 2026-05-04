import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.settings,
  });

  final SettingsProvider settings;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _endpointController;
  late final TextEditingController _apiKeyController;

  late ThemeMode _themeMode;
  late String _language;
  late bool _onlineTutorEnabled;
  late bool _cloudSyncEnabled;
  late bool _speakAnswers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.settings.userName);
    _endpointController = TextEditingController(text: widget.settings.apiEndpoint);
    _apiKeyController = TextEditingController(text: widget.settings.apiKey);
    _themeMode = widget.settings.themeMode;
    _language = widget.settings.tutorLanguage;
    _onlineTutorEnabled = widget.settings.onlineTutorEnabled;
    _cloudSyncEnabled = widget.settings.cloudSyncEnabled;
    _speakAnswers = widget.settings.speakAnswers;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Tutor & Sync Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'User name',
                helperText: 'Used in reminders and study greetings.',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              initialValue: _themeMode,
              decoration: const InputDecoration(labelText: 'Theme mode'),
              items: ThemeMode.values
                  .map(
                    (ThemeMode mode) => DropdownMenuItem<ThemeMode>(
                      value: mode,
                      child: Text(mode.name),
                    ),
                  )
                  .toList(),
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  setState(() => _themeMode = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Tutor language'),
              items: AppConstants.tutorLanguages
                  .map(
                    (String language) => DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _language = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _onlineTutorEnabled,
              title: const Text('Online tutor'),
              subtitle: const Text('Uses your configured API when available.'),
              onChanged: (bool value) => setState(() => _onlineTutorEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _cloudSyncEnabled,
              title: const Text('Cloud sync toggle'),
              subtitle: const Text('Keeps the app ready for optional Firebase sync later.'),
              onChanged: (bool value) => setState(() => _cloudSyncEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _speakAnswers,
              title: const Text('Read tutor answers aloud'),
              onChanged: (bool value) => setState(() => _speakAnswers = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'AI endpoint URL',
                helperText: 'Add your backend URL here.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API key',
                helperText: 'Stored locally on your device.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                await widget.settings.updateUserName(_nameController.text);
                await widget.settings.updateThemeMode(_themeMode);
                await widget.settings.updateTutorLanguage(_language);
                await widget.settings.updateOnlineTutorEnabled(_onlineTutorEnabled);
                await widget.settings.updateCloudSyncEnabled(_cloudSyncEnabled);
                await widget.settings.updateSpeakAnswers(_speakAnswers);
                await widget.settings.updateApiEndpoint(_endpointController.text);
                await widget.settings.updateApiKey(_apiKeyController.text);
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save settings'),
            ),
          ],
        ),
      ),
    );
  }
}
