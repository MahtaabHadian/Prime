import 'package:flutter/material.dart';
import 'package:prime/models/task.dart';
import 'package:uuid/uuid.dart';

// Helper function to convert Color to String (hex code with alpha)
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

// Helper function to convert String (hex code with alpha) back to Color
Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) {
    buffer.write('ff'); // Add alpha if missing (assume fully opaque)
  }
  buffer.write(hexString.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e) {
    print("Error parsing color: $hexString. Using default grey.");
    return Colors.grey; // Default color on error
  }
}


class Project {
  String id;
  String title;
  List<Task> tasks;
  Color color;
  String imagePath;

  Project({
    required this.title,
    required this.color,
    required this.imagePath,
    List<Task>? tasks,
    String? id,
  }) : id = id ?? const Uuid().v4(),
        tasks = tasks ?? [];

  int get completedTasksCount => tasks.where((task) => task.isDone).length;
  int get totalTasksCount => tasks.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'color': colorToHex(color),
    'imagePath': imagePath,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? 'Untitled Project',
      color: hexToColor(json['color'] as String? ?? '#808080'),
      imagePath: json['imagePath'] as String? ?? 'assets/img/bg.png', // Default image
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((taskJson) {
        if (taskJson is Map<String, dynamic>) {
          return Task.fromJson(taskJson);
        } else { return null; }
      })
          ?.whereType<Task>()
          .toList() ??
          [],
    );
  }
}