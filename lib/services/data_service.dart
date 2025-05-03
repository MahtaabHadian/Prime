import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:prime/models/project.dart';

class DataService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/projects_data.json');
  }

  Future<List<Project>> loadProjects() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        print("Data file not found. Starting fresh.");
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        print("Data file is empty. Starting fresh.");
        return [];
      }
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error loading projects: $e");
      // Optional: try deleting the file if corrupted?
      // await deleteDataFile();
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    try {
      final file = await _localFile;
      final List<Map<String, dynamic>> jsonList =
      projects.map((p) => p.toJson()).toList();
      final String jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
      print("Projects saved successfully.");
    } catch (e) {
      print("Error saving projects: $e");
    }
  }

  Future<void> deleteDataFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        print("Data file deleted successfully.");
      } else {
        print("Data file did not exist, nothing to delete.");
      }
    } catch (e) {
      print("Error deleting data file: $e");
    }
  }
}