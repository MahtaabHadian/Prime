import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, urgent }
enum TaskCategory { work, personal, shopping, health, other }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String projectId;
  final TaskPriority priority;
  final TaskCategory category;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.projectId,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.isCompleted = false,
    String? id,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  String get priorityText {
    switch (priority) {
      case TaskPriority.low:
        return 'کم';
      case TaskPriority.medium:
        return 'متوسط';
      case TaskPriority.high:
        return 'بالا';
      case TaskPriority.urgent:
        return 'فوری';
    }
  }

  String get categoryText {
    switch (category) {
      case TaskCategory.work:
        return 'کار';
      case TaskCategory.personal:
        return 'شخصی';
      case TaskCategory.shopping:
        return 'خرید';
      case TaskCategory.health:
        return 'سلامتی';
      case TaskCategory.other:
        return 'سایر';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getTasksByCategory(TaskCategory category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) => !task.isCompleted && task.dueDate.isBefore(now)).toList();
  }

  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _tasks.where((task) => 
      !task.isCompleted && 
      task.dueDate.isAfter(today) && 
      task.dueDate.isBefore(tomorrow)
    ).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      if (_tasks[index].isCompleted) {
        _tasks[index].completedAt = DateTime.now();
      } else {
        _tasks[index].completedAt = null;
      }
      notifyListeners();
    }
  }
} 