import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_identity.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/study_data_provider.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/gradient_card.dart';
import '../widgets/pomodoro_panel.dart';
import '../widgets/routine_tile.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final StudyDataProvider study = context.watch<StudyDataProvider>();
    final PomodoroProvider pomodoro = context.watch<PomodoroProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hello ${settings.userName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppIdentity.appName} keeps your study plan, AI tutor, reminders, and focus sessions ready even when you are offline.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  study.motivation.english,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(study.motivation.bengali),
                const SizedBox(height: 8),
                Text('Focus tip: ${study.motivation.tip}'),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => onNavigate(3),
                      icon: const Icon(Icons.smart_toy_rounded),
                      label: const Text('Ask Tutor'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate(1),
                      icon: const Icon(Icons.schedule_rounded),
                      label: const Text('Plan Routine'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: <Widget>[
              StatChip(label: 'Current streak', value: '${study.streak} days', icon: Icons.local_fire_department_rounded),
              StatChip(label: 'Today\'s tasks', value: '${study.completedRoutineCountToday}/${study.todayRoutines.length}', icon: Icons.task_alt_rounded),
              StatChip(label: 'Focus today', value: '${pomodoro.todayFocusMinutes} min', icon: Icons.timer_rounded),
              StatChip(label: 'Goals done', value: '${study.completedGoalCount}', icon: Icons.flag_rounded),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Focus Booster',
            subtitle: 'Pomodoro sessions and recovery breaks',
          ),
          const SizedBox(height: 12),
          const PomodoroPanel(),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Upcoming Routine',
            subtitle: 'Your next study blocks',
            trailing: TextButton(
              onPressed: () => onNavigate(1),
              child: const Text('Open'),
            ),
          ),
          const SizedBox(height: 12),
          if (study.upcomingRoutines.isEmpty)
            const EmptyStateCard(
              title: 'No routine yet',
              message: 'Create a daily plan or let Shindhu suggest a smart study routine.',
              icon: Icons.event_busy_rounded,
            )
          else
            ...study.upcomingRoutines.take(3).map(
                  (task) => RoutineTile(
                    task: task,
                    onToggle: (bool value) => context.read<StudyDataProvider>().toggleRoutineCompletion(task, value),
                  ),
                ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Daily GK Feed',
            subtitle: 'Offline facts to keep your revision sharp',
          ),
          const SizedBox(height: 12),
          ...study.gkFeed.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.category, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(item.summary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
