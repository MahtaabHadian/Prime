import 'package:flutter/foundation.dart';
import 'package:prime/providers/task_provider.dart';

class SearchProvider with ChangeNotifier {
  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  TaskCategory? _selectedCategory;
  bool _showCompleted = true;
  bool _showOverdue = true;

  String get searchQuery => _searchQuery;
  TaskPriority? get selectedPriority => _selectedPriority;
  TaskCategory? get selectedCategory => _selectedCategory;
  bool get showCompleted => _showCompleted;
  bool get showOverdue => _showOverdue;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  void toggleShowOverdue() {
    _showOverdue = !_showOverdue;
    notifyListeners();
  }

  List<Task> filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Priority filter
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && task.category != _selectedCategory) {
        return false;
      }

      // Completed tasks filter
      if (!_showCompleted && task.isCompleted) {
        return false;
      }

      // Overdue tasks filter
      if (!_showOverdue && !task.isCompleted && task.dueDate.isBefore(DateTime.now())) {
        return false;
      }

      return true;
    }).toList();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedPriority = null;
    _selectedCategory = null;
    _showCompleted = true;
    _showOverdue = true;
    notifyListeners();
  }
} 