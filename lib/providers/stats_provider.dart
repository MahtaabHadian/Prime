import 'package:flutter/foundation.dart';
import 'package:prime/providers/task_provider.dart';

class TaskStats {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int todayTasks;
  final Map<TaskPriority, int> priorityDistribution;
  final Map<TaskCategory, int> categoryDistribution;
  final double completionRate;
  final double onTimeRate;

  TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.todayTasks,
    required this.priorityDistribution,
    required this.categoryDistribution,
    required this.completionRate,
    required this.onTimeRate,
  });
}

class StatsProvider with ChangeNotifier {
  final TaskProvider _taskProvider;

  StatsProvider(this._taskProvider) {
    _taskProvider.addListener(_updateStats);
  }

  TaskStats? _stats;
  TaskStats? get stats => _stats;

  void _updateStats() {
    final tasks = _taskProvider.tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final overdueTasks = tasks.where((task) => 
      !task.isCompleted && task.dueDate.isBefore(now)
    ).length;
    final todayTasks = tasks.where((task) => 
      !task.isCompleted && 
      task.dueDate.isAfter(today) && 
      task.dueDate.isBefore(tomorrow)
    ).length;

    final priorityDistribution = <TaskPriority, int>{};
    final categoryDistribution = <TaskCategory, int>{};

    for (final task in tasks) {
      priorityDistribution[task.priority] = 
        (priorityDistribution[task.priority] ?? 0) + 1;
      categoryDistribution[task.category] = 
        (categoryDistribution[task.category] ?? 0) + 1;
    }

    final completionRate = tasks.isEmpty ? 0.0 : 
      (completedTasks / tasks.length) * 100;

    final onTimeTasks = tasks.where((task) => 
      task.isCompleted && 
      task.completedAt != null && 
      task.completedAt!.isBefore(task.dueDate)
    ).length;

    final onTimeRate = completedTasks == 0 ? 0.0 : 
      (onTimeTasks / completedTasks) * 100;

    _stats = TaskStats(
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      todayTasks: todayTasks,
      priorityDistribution: priorityDistribution,
      categoryDistribution: categoryDistribution,
      completionRate: completionRate,
      onTimeRate: onTimeRate,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _taskProvider.removeListener(_updateStats);
    super.dispose();
  }
} 