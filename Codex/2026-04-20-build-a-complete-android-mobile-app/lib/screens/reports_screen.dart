import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/goal.dart';
import '../models/study_note.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/study_data_provider.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/goal_tile.dart';
import '../widgets/gradient_card.dart';
import '../widgets/pomodoro_panel.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/stat_chip.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudyDataProvider study = context.watch<StudyDataProvider>();
    final PomodoroProvider pomodoro = context.watch<PomodoroProvider>();
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Reports & Goals', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Track study progress, goal completion, notes, streaks, and tutor configuration from one place.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => _showGoalSheet(context),
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('Add Goal'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showNoteSheet(context),
                      icon: const Icon(Icons.note_add_rounded),
                      label: const Text('Add Note'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showSettings(context, settings),
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Settings'),
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
              StatChip(label: 'Completed goals', value: '${study.completedGoalCount}', icon: Icons.flag_rounded),
              StatChip(label: 'Goal success', value: '${(study.goalCompletionRate * 100).round()}%', icon: Icons.trending_up_rounded),
              StatChip(label: 'Sessions done', value: '${pomodoro.completedSessions}', icon: Icons.timer_rounded),
              StatChip(label: 'Weekly focus', value: '${pomodoro.weeklyFocusMinutes} min', icon: Icons.analytics_rounded),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Goal Tracker',
            subtitle: 'Daily, weekly, and monthly targets',
          ),
          const SizedBox(height: 12),
          if (study.activeGoals.isEmpty)
            const EmptyStateCard(
              title: 'No goals yet',
              message: 'Create a measurable goal to track consistent progress.',
              icon: Icons.flag_circle_rounded,
            )
          else
            ...study.activeGoals.map(
              (goal) => GoalTile(
                goal: goal,
                onIncrement: () => context.read<StudyDataProvider>().incrementGoal(goal),
                onDelete: () => context.read<StudyDataProvider>().deleteGoal(goal.id),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Notes Library',
            subtitle: 'Subject-wise quick revision notes',
          ),
          const SizedBox(height: 12),
          if (study.recentNotes.isEmpty)
            const EmptyStateCard(
              title: 'No notes yet',
              message: 'Save formula lists, revision bullets, or shortcut tricks here.',
              icon: Icons.menu_book_rounded,
            )
          else
            ...study.recentNotes.map(
              (note) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(note.subject, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Text(note.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(note.content, maxLines: 4, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context.read<StudyDataProvider>().deleteNote(note.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Pomodoro Analytics',
            subtitle: 'Focus timer controls and progress',
          ),
          const SizedBox(height: 12),
          const PomodoroPanel(),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Sync Status',
            subtitle: 'Local-first reliability',
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
                Text('Online tutor configured: ${settings.hasOnlineConfig ? 'Yes' : 'No'}'),
                const SizedBox(height: 8),
                Text('Cloud sync enabled: ${settings.cloudSyncEnabled ? 'Yes' : 'No'}'),
                const SizedBox(height: 8),
                Text(study.syncStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettings(BuildContext context, SettingsProvider settings) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SettingsSheet(settings: settings),
    );
  }

  Future<void> _showGoalSheet(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController categoryController = TextEditingController(text: 'SSC');
    String timeframe = AppConstants.goalTimeframes.first;
    double target = 5;
    DateTime dueDate = DateTime.now();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Create Goal', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Goal title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: timeframe,
                      decoration: const InputDecoration(labelText: 'Timeframe'),
                      items: AppConstants.goalTimeframes
                          .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setModalState(() => timeframe = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Target count: ${target.round()}'),
                    Slider(
                      min: 1,
                      max: 20,
                      divisions: 19,
                      value: target,
                      onChanged: (double value) => setModalState(() => target = value),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Due date: ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: () async {
                        final DateTime? value = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDate: dueDate,
                        );
                        if (value != null) {
                          setModalState(() => dueDate = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final String title = titleController.text.trim();
                        if (title.isEmpty) {
                          return;
                        }
                        final Goal goal = Goal(
                          id: 'goal_${DateTime.now().microsecondsSinceEpoch}',
                          title: title,
                          category: categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
                          timeframe: timeframe,
                          targetCount: target.round(),
                          completedCount: 0,
                          dueDate: dueDate,
                          isCompleted: false,
                        );
                        await context.read<StudyDataProvider>().addGoal(goal);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('Save goal'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
  }

  Future<void> _showNoteSheet(BuildContext context) async {
    final TextEditingController subjectController = TextEditingController(text: AppConstants.subjectSuggestions.first);
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Add Study Note', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final String title = titleController.text.trim();
                    final String content = contentController.text.trim();
                    if (title.isEmpty || content.isEmpty) {
                      return;
                    }
                    final StudyNote note = StudyNote(
                      id: 'note_${DateTime.now().microsecondsSinceEpoch}',
                      subject: subjectController.text.trim().isEmpty ? 'General' : subjectController.text.trim(),
                      title: title,
                      content: content,
                      updatedAt: DateTime.now(),
                    );
                    await context.read<StudyDataProvider>().addOrUpdateNote(note);
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save note'),
                ),
              ],
            ),
          ),
        );
      },
    );

    subjectController.dispose();
    titleController.dispose();
    contentController.dispose();
  }
}
