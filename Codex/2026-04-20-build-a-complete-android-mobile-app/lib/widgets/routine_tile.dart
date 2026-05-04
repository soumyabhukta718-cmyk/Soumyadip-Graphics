import 'package:flutter/material.dart';

import '../core/utils/date_time_utils.dart';
import '../models/routine_task.dart';

class RoutineTile extends StatelessWidget {
  const RoutineTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
  });

  final RoutineTask task;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) => onToggle(value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.subject} • ${DateTimeUtils.formatDay(task.date)} • ${DateTimeUtils.formatTimeRange(task.startMinute, task.endMinute)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (task.notes.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(task.notes, style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Icon(
                task.reminderEnabled ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
