import 'dart:async';
import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import 'package:usage_stats/usage_stats.dart';
import 'task_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The callback function should be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(AppMonitorTaskHandler());
}

class AppMonitorService {
  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'task_lock_monitor',
        channelName: 'App Monitor',
        channelDescription: 'Monitors foreground apps for locking',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          5000,
        ), // Check every 5 seconds
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> startMonitoring() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.startService(
      notificationTitle: 'Task Lock Active',
      notificationText: 'Monitoring apps...',
      callback: startCallback,
    );
  }

  Future<void> stopMonitoring() async {
    await FlutterForegroundTask.stopService();
  }

  Future<Map<String, bool>> checkPermissions() async {
    bool overlayGranted =
        await overlay.FlutterOverlayWindow.isPermissionGranted();

    // Use the proper platform-level permission check
    bool usageGranted = false;
    try {
      usageGranted = (await UsageStats.checkUsagePermission()) ?? false;
    } catch (e) {
      usageGranted = false;
    }

    return {
      'usage': usageGranted,
      'overlay': overlayGranted,
      'notification': true,
    };
  }

  Future<void> requestUsageStatsPermission() async {
    await UsageStats.grantUsagePermission();
  }

  Future<void> requestOverlayPermission() async {
    await overlay.FlutterOverlayWindow.requestPermission();
  }

  Future<void> updateLockedApps(List<String> packageNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locked_apps', packageNames);
  }

  Future<void> updateTasksCompleted(bool allDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('all_tasks_done', allDone);
  }
}

class AppMonitorTaskHandler extends TaskHandler {
  List<String> _lockedApps = [];
  bool _allTasksDone = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _lockedApps = prefs.getStringList('locked_apps') ?? [];
    _allTasksDone = prefs.getBool('all_tasks_done') ?? false;
    print(
      '[TaskLock] Service started. Locked apps: $_lockedApps, allDone: $_allTasksDone',
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkApps();
  }

  Future<void> _checkApps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lockedApps = prefs.getStringList('locked_apps') ?? [];
    _allTasksDone = prefs.getBool('all_tasks_done') ?? false;

    // Check Snooze Timer
    // If the user dismissed the overlay recently, respect the snooze period.
    final int snoozeUntil = prefs.getInt('overlay_snooze_until') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < snoozeUntil) {
      // Snoozed. Do not show overlay.
      return;
    }

    print(
      '[TaskLock] Check: locked=${_lockedApps.length}, allDone=$_allTasksDone',
    );

    if (_allTasksDone) {
      try {
        bool isActive = await overlay.FlutterOverlayWindow.isActive();
        if (isActive) {
          await overlay.FlutterOverlayWindow.closeOverlay();
        }
      } catch (_) {}
      return;
    }

    if (_lockedApps.isEmpty) return;

    String? currentForegroundPackage;

    try {
      final DateTime end = DateTime.now();
      final DateTime start = end.subtract(const Duration(seconds: 30));

      // Strategy 1: Try queryEvents first
      try {
        final List<EventUsageInfo> events = await UsageStats.queryEvents(
          start,
          end,
        );
        print('[TaskLock] Events count: ${events.length}');

        // Try multiple foreground event type values
        int latestTimestamp = 0;
        for (final event in events) {
          final eventType = event.eventType;
          final ts = int.tryParse(event.timeStamp ?? '0') ?? 0;

          // Accept type 1 (foreground) or type 7 (user interaction)
          if ((eventType == '1' || eventType == '7') && ts > latestTimestamp) {
            latestTimestamp = ts;
            currentForegroundPackage = event.packageName;
          }
        }
        print('[TaskLock] Events strategy result: $currentForegroundPackage');
      } catch (e) {
        print('[TaskLock] queryEvents failed: $e');
      }

      // Strategy 2: Fallback to queryUsageStats if events didn't work
      if (currentForegroundPackage == null) {
        final widerStart = end.subtract(const Duration(hours: 24));
        final List<UsageInfo> stats = await UsageStats.queryUsageStats(
          widerStart,
          end,
        );
        print('[TaskLock] Stats count: ${stats.length}');

        if (stats.isNotEmpty) {
          // Filter out entries with null/zero lastTimeUsed, then sort by most recent
          final validStats = stats.where((s) {
            final ltu = int.tryParse(s.lastTimeUsed ?? '0') ?? 0;
            return ltu > 0 && s.packageName != null;
          }).toList();

          validStats.sort((a, b) {
            final aTime = int.parse(a.lastTimeUsed!);
            final bTime = int.parse(b.lastTimeUsed!);
            return bTime.compareTo(aTime);
          });

          if (validStats.isNotEmpty) {
            currentForegroundPackage = validStats.first.packageName;
          }
        }
        print('[TaskLock] Stats strategy result: $currentForegroundPackage');
      }

      // Now check if the detected foreground app is locked
      if (currentForegroundPackage != null &&
          _lockedApps.contains(currentForegroundPackage)) {
        bool isActive = await overlay.FlutterOverlayWindow.isActive();
        if (!isActive) {
          // Check overlay permission first
          bool hasOverlayPermission =
              await overlay.FlutterOverlayWindow.isPermissionGranted();
          print('[TaskLock] Overlay permission: $hasOverlayPermission');

          if (hasOverlayPermission) {
            print(
              '[TaskLock] BLOCKING $currentForegroundPackage - showing overlay...',
            );
            try {
              await overlay.FlutterOverlayWindow.showOverlay(
                enableDrag: false,
                height: -1, // Full screen
                width: -1, // Full screen
                alignment: overlay.OverlayAlignment.center,
                flag: overlay.OverlayFlag.focusPointer,
                visibility: overlay.NotificationVisibility.visibilitySecret,
                positionGravity: overlay.PositionGravity.none,
              );

              // Push the task data from FILE STORAGE (reliable)
              try {
                final tasks = await TaskStorageService().loadTasks();
                final tasksJson = jsonEncode(
                  tasks.map((t) => t.toMap()).toList(),
                );

                // Wait a brief moment for the overlay to initialize listeners
                await Future.delayed(const Duration(milliseconds: 500));
                await overlay.FlutterOverlayWindow.shareData(tasksJson);
              } catch (e) {
                print('[TaskLock] Error loading/sharing tasks from file: $e');
              }

              print('[TaskLock] showOverlay() completed and data shared');
            } catch (overlayError) {
              print('[TaskLock] showOverlay() FAILED: $overlayError');
            }
          } else {
            print('[TaskLock] Cannot show overlay - permission not granted!');
          }
        }
      }
    } catch (e, st) {
      print('[TaskLock] Monitor Error: $e\n$st');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isRestoring) async {
    // Cleanup if needed
  }

  @override
  void onNotificationPressed() {}
}
