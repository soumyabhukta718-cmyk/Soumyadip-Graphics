import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroPanel extends StatefulWidget {
  const PomodoroPanel({super.key});

  @override
  State<PomodoroPanel> createState() => _PomodoroPanelState();
}

class _PomodoroPanelState extends State<PomodoroPanel> {
  String _selectedSubject = AppConstants.subjectSuggestions.first;
  int _selectedFocus = 25;
  int _selectedBreak = 5;

  @override
  Widget build(BuildContext context) {
    final PomodoroProvider provider = context.watch<PomodoroProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Pomodoro Timer', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(
            provider.formattedRemaining,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 6),
          Text(provider.phaseLabel, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (!provider.isRunning && !provider.isPaused) ...<Widget>[
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: AppConstants.subjectSuggestions
                  .map(
                    (String subject) => DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _selectedSubject = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <int>[25, 45, 60]
                  .map(
                    (int value) => ChoiceChip(
                      label: Text('$value min focus'),
                      selected: _selectedFocus == value,
                      onSelected: (_) => setState(() => _selectedFocus = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <int>[5, 10, 15]
                  .map(
                    (int value) => ChoiceChip(
                      label: Text('$value min break'),
                      selected: _selectedBreak == value,
                      onSelected: (_) => setState(() => _selectedBreak = value),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: provider.isRunning
                    ? null
                    : () {
                        if (provider.isPaused) {
                          provider.resume();
                        } else {
                          provider.start(
                            subject: _selectedSubject,
                            focusMinutes: _selectedFocus,
                            breakMinutes: _selectedBreak,
                          );
                        }
                      },
                icon: Icon(provider.isPaused ? Icons.play_arrow_rounded : Icons.timer_rounded),
                label: Text(provider.isPaused ? 'Resume' : 'Start'),
              ),
              OutlinedButton.icon(
                onPressed: provider.isRunning ? provider.pause : provider.reset,
                icon: Icon(provider.isRunning ? Icons.pause_rounded : Icons.replay_rounded),
                label: Text(provider.isRunning ? 'Pause' : 'Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Today: ${provider.todayFocusMinutes} min • Week: ${provider.weeklyFocusMinutes} min • Sessions: ${provider.completedSessions}',
          ),
        ],
      ),
    );
  }
}
