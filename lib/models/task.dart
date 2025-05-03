import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String description;
  final String date;
  final bool isDone;

  Task({
    required this.id,
    required this.description,
    required this.date,
    this.isDone = false,
  });

  Task copyWith({
    String? id,
    String? description,
    String? date,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'date': date,
    'isDone': isDone,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? const Uuid().v4(),
      description: json['description'] as String? ?? 'No Description',
      date: json['date'] as String? ?? 'No Date',
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}