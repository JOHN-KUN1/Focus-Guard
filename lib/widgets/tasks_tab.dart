import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks for today.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.tasks.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            return Dismissible(
              key: Key(task.id.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => provider.deleteTask(index),
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => provider.toggleTask(index),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    checkColor: Colors.white,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.white54,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
