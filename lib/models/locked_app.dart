import 'dart:typed_data';

class LockedApp {
  final String packageName;
  final String appName;
  final Uint8List?
  iconBytes; // Optional, for display in UI, might not store in DB efficiently if large

  LockedApp({required this.packageName, required this.appName, this.iconBytes});

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      // We generally don't store icon bytes in DB, we fetch them via package manager.
      // But if we want to cache, we could. For simplicity, we'll fetch icons fresh or store minimally.
    };
  }

  factory LockedApp.fromMap(Map<String, dynamic> map) {
    return LockedApp(packageName: map['packageName'], appName: map['appName']);
  }
}
