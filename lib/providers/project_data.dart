import 'dart:math'; // For Random
import 'package:flutter/material.dart';
import 'package:prime/models/project.dart';
import 'package:prime/models/task.dart';
import 'package:prime/services/data_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ProjectData with ChangeNotifier {
  final DataService _dataService = DataService();
  final List<Project> _projects = [];
  bool _isLoading = false;

  static const List<String> _availableBackgrounds = [
    'assets/img/bg.png',
    'assets/img/bg2.png',
    'assets/img/bg3.png',
    'assets/img/bg4.png',
  ];
  final Random _random = Random();

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectData() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveProjects() async {
    _dataService.saveProjects(_projects).catchError((e) {
      print("Background save failed: $e");
    });
  }

  Project? findProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  void addProject(String title, Color color) {
    final project = Project(
      id: const Uuid().v4(),
      title: title,
      color: color,
      imagePath: 'assets/img/bg${(_projects.length % 4) + 1}.png',
    );
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void deleteProject(String projectId) {
    _projects.removeWhere((project) => project.id == projectId);
    _saveProjects();
    notifyListeners();
  }

  void addTask(String projectId, String description, String date) {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      final task = Task(
        id: const Uuid().v4(),
        description: description,
        date: date,
      );
      _projects[projectIndex].tasks.add(task);
      _saveProjects();
      notifyListeners();
    }
  }

  void deleteTask(String projectId, String taskId) {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      _projects[projectIndex].tasks.removeWhere((task) => task.id == taskId);
      _saveProjects();
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String projectId, String taskId) {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      final taskIndex = _projects[projectIndex].tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _projects[projectIndex].tasks[taskIndex];
        _projects[projectIndex].tasks[taskIndex] = Task(
          id: task.id,
          description: task.description,
          date: task.date,
          isDone: !task.isDone,
        );
        _saveProjects();
        notifyListeners();
      }
    }
  }

  void updateProjectDetails(String projectId, {String? newTitle, Color? newColor}) {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      final project = _projects[projectIndex];
      _projects[projectIndex] = Project(
        id: project.id,
        title: newTitle ?? project.title,
        color: newColor ?? project.color,
        imagePath: project.imagePath,
        tasks: project.tasks,
      );
      _saveProjects();
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    _projects.clear();
    await _dataService.deleteDataFile();
    print("All project data cleared.");
    notifyListeners();
  }
}