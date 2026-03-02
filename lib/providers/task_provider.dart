import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/app_monitor_service.dart';
import '../services/task_storage.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final AppMonitorService _monitorService = AppMonitorService();

  List<Task> get tasks => _tasks;

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getTasksForDate(_todayStr);
    notifyListeners();
    _checkCompletionStatus();
    _saveTasksToPrefs();
  }

  Future<void> addTask(String title) async {
    final newTask = Task(title: title, createdAt: _todayStr);
    final savedTask = await DatabaseHelper.instance.createTask(newTask);
    _tasks.add(savedTask);
    notifyListeners();
    _checkCompletionStatus();
    _saveTasksToPrefs();
  }

  Future<void> toggleTask(int index) async {
    final task = _tasks[index];
    final updatedTask = task.copyWith(isDone: !task.isDone);
    await DatabaseHelper.instance.updateTask(updatedTask);
    _tasks[index] = updatedTask;
    notifyListeners();
    _checkCompletionStatus();
    _saveTasksToPrefs();
  }

  Future<void> deleteTask(int index) async {
    final task = _tasks[index];
    if (task.id != null) {
      await DatabaseHelper.instance.deleteTask(task.id!);
      _tasks.removeAt(index);
      notifyListeners();
      _checkCompletionStatus();
      _saveTasksToPrefs();
    }
  }

  void _checkCompletionStatus() {
    if (_tasks.isEmpty) {
      _monitorService.updateTasksCompleted(true);
      return;
    }

    final allDone = _tasks.every((t) => t.isDone);
    _monitorService.updateTasksCompleted(allDone);
  }

  Future<void> _saveTasksToPrefs() async {
    // Save to SharedPreferences as backup (and for legacy read if needed)
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => t.toMap()).toList();
    await prefs.setString('current_tasks_list', jsonEncode(tasksJson));

    // Check if empty
    final allDone = _tasks.isEmpty || _tasks.every((t) => t.isDone);
    await prefs.setBool('all_tasks_done', allDone);

    // Save to File Storage for Overlay access
    await TaskStorageService().saveTasks(_tasks);
  }
}
