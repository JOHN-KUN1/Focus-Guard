import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class TaskStorageService {
  static final TaskStorageService _instance = TaskStorageService._internal();
  factory TaskStorageService() => _instance;
  TaskStorageService._internal();

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/current_tasks.json');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }
      final String content = await file.readAsString();
      if (content.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => Task.fromMap(e)).toList();
    } catch (e) {
      print('Error loading tasks from file: $e');
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final file = await _file;
      final String content = jsonEncode(tasks.map((e) => e.toMap()).toList());
      await file.writeAsString(content);

      // Also update the completion flag
      // final allDone = tasks.isNotEmpty && tasks.every((t) => t.isDone);

      // We assume the service monitors this separately via reading the file or we can update prefs too if needed?
      // Actually, updating prefs is still a good "signal" for the background service
      // But if prefs is broken, the service should read the file to check status.
    } catch (e) {
      print('Error saving tasks to file: $e');
    }
  }
}
