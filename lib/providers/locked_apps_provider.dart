import 'package:flutter/material.dart';
import '../models/locked_app.dart';
import '../services/database_helper.dart';
import '../services/app_monitor_service.dart';

class LockedAppsProvider with ChangeNotifier {
  List<LockedApp> _lockedApps = [];
  final AppMonitorService _monitorService = AppMonitorService();

  List<LockedApp> get lockedApps => _lockedApps;

  Future<void> loadLockedApps() async {
    final apps = await DatabaseHelper.instance.getLockedApps();
    _lockedApps = apps;
    notifyListeners();
    _syncWithNative();
  }

  Future<void> addLockedApp(LockedApp app) async {
    // Check if already exists
    if (_lockedApps.any((a) => a.packageName == app.packageName)) return;

    await DatabaseHelper.instance.addLockedApp(app);
    _lockedApps.add(app);
    notifyListeners();
    _syncWithNative();
  }

  Future<void> removeLockedApp(String packageName) async {
    await DatabaseHelper.instance.removeLockedApp(packageName);
    _lockedApps.removeWhere((a) => a.packageName == packageName);
    notifyListeners();
    _syncWithNative();
  }

  void _syncWithNative() {
    final packageNames = _lockedApps.map((a) => a.packageName).toList();
    _monitorService.updateLockedApps(packageNames);
  }
}
