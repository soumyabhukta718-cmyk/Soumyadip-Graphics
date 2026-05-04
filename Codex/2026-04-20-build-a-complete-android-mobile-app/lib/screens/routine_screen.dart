import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_time_utils.dart';
import '../models/routine_task.dart';
import '../providers/study_data_provider.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/gradient_card.dart';
import '../widgets/routine_tile.dart';
import '../widgets/section_title.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('Smart Routine Planner', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Create your own study slots or let Shindhu generate a balanced daily routine. Missed tasks can be auto-rescheduled offline.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => _showAddRoutineSheet(context),
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Add Task'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showSmartPlanSheet(context),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('AI Suggest'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.read<StudyDataProvider>().rescheduleMissedTasks(),
                      icon: const Icon(Icons.update_rounded),
                      label: const Text('Reschedule'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Today\'s Routine',
            subtitle: 'Stay on track with timed study blocks',
          ),
          const SizedBox(height: 12),
          if (study.todayRoutines.isEmpty)
            const EmptyStateCard(
              title: 'No tasks scheduled',
              message: 'Add your first routine block or generate a smart plan.',
              icon: Icons.schedule_rounded,
            )
          else
            ...study.todayRoutines.map(
              (task) => RoutineTile(
                task: task,
                onToggle: (bool value) => context.read<StudyDataProvider>().toggleRoutineCompletion(task, value),
                onDelete: () => context.read<StudyDataProvider>().deleteRoutine(task.id),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Upcoming Tasks',
            subtitle: 'Future scheduled study sessions',
          ),
          const SizedBox(height: 12),
          if (study.upcomingRoutines.isEmpty)
            const EmptyStateCard(
              title: 'Nothing upcoming',
              message: 'Your next suggested sessions will appear here.',
              icon: Icons.upcoming_rounded,
            )
          else
            ...study.upcomingRoutines.map(
              (task) => RoutineTile(
                task: task,
                onToggle: (bool value) => context.read<StudyDataProvider>().toggleRoutineCompletion(task, value),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddRoutineSheet(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 6, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 7, minute: 0);
    String subject = AppConstants.subjectSuggestions.first;
    bool reminderEnabled = true;

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
                    Text('Add Routine Task', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Task title'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: subject,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: AppConstants.subjectSuggestions
                          .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setModalState(() => subject = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date: ${DateTimeUtils.formatDate(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: () async {
                        final DateTime? value = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDate: selectedDate,
                        );
                        if (value != null) {
                          setModalState(() => selectedDate = value);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Start: ${startTime.format(context)}'),
                      trailing: const Icon(Icons.access_time_rounded),
                      onTap: () async {
                        final TimeOfDay? value = await showTimePicker(context: context, initialTime: startTime);
                        if (value != null) {
                          setModalState(() => startTime = value);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('End: ${endTime.format(context)}'),
                      trailing: const Icon(Icons.access_time_filled_rounded),
                      onTap: () async {
                        final TimeOfDay? value = await showTimePicker(context: context, initialTime: endTime);
                        if (value != null) {
                          setModalState(() => endTime = value);
                        }
                      },
                    ),
                    SwitchListTile(
                      value: reminderEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Alarm and reminder'),
                      onChanged: (bool value) => setModalState(() => reminderEnabled = value),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        final String title = titleController.text.trim();
                        if (title.isEmpty) {
                          return;
                        }
                        final RoutineTask task = RoutineTask(
                          id: 'routine_${DateTime.now().microsecondsSinceEpoch}',
                          title: title,
                          subject: subject,
                          date: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                          startMinute: DateTimeUtils.toMinutes(startTime),
                          endMinute: DateTimeUtils.toMinutes(endTime),
                          isCompleted: false,
                          reminderEnabled: reminderEnabled,
                          notes: '',
                        );
                        await context.read<StudyDataProvider>().addRoutine(task);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save task'),
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
  }

  Future<void> _showSmartPlanSheet(BuildContext context) async {
    final TextEditingController subjectsController = TextEditingController(
      text: 'Mathematics, Reasoning, English, General Knowledge',
    );
    double studyHours = 4;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Generate Smart Routine', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Subjects',
                      helperText: 'Separate subjects with commas.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Study hours: ${studyHours.round()}'),
                  Slider(
                    min: 2,
                    max: 8,
                    divisions: 6,
                    value: studyHours,
                    label: studyHours.round().toString(),
                    onChanged: (double value) => setModalState(() => studyHours = value),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final List<String> subjects = subjectsController.text
                          .split(',')
                          .map((String value) => value.trim())
                          .where((String value) => value.isNotEmpty)
                          .toList();
                      await context.read<StudyDataProvider>().generateSmartRoutine(
                            subjects: subjects,
                            studyHours: studyHours.round(),
                          );
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Create routine'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    subjectsController.dispose();
  }
}
