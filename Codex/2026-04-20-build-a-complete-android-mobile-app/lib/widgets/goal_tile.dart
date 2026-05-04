import 'package:flutter/material.dart';

import '../models/goal.dart';

class GoalTile extends StatelessWidget {
  const GoalTile({
    super.key,
    required this.goal,
    required this.onIncrement,
    this.onDelete,
  });

  final Goal goal;
  final VoidCallback onIncrement;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          Text(
            '${goal.timeframe} • ${goal.category}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text('${goal.completedCount}/${goal.targetCount} completed'),
              ),
              FilledButton.tonalIcon(
                onPressed: goal.isCompleted ? null : onIncrement,
                icon: const Icon(Icons.flag_rounded),
                label: Text(goal.isCompleted ? 'Done' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
