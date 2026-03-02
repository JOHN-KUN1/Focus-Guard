import 'package:flutter/material.dart';
import '../services/app_monitor_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  final AppMonitorService _service = AppMonitorService();
  Map<String, bool> _statuses = {
    'usage': false,
    'overlay': false,
    'notification': false, // Only matters for Android 13+ logic
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final statuses = await _service.checkPermissions();
    setState(() {
      _statuses = statuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Required Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'To lock apps and detect when they are opened, this app needs the following permissions:',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildPermissionTile(
            title: 'Usage Access',
            subtitle: 'Required to detect which app is currently open.',
            isGranted: _statuses['usage'] ?? false,
            onTap: () => _service.requestUsageStatsPermission(),
          ),
          _buildPermissionTile(
            title: 'Display Over Apps',
            subtitle: 'Required to show the lock screen over other apps.',
            isGranted: _statuses['overlay'] ?? false,
            onTap: () => _service.requestOverlayPermission(),
          ),
          // Notification permission logic could be auto-handled or requested if on Android 13+
          // For simplicity, we just show these two critical ones.
          // If we want notification permission request:
          // _buildPermissionTile(...)
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: isGranted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(onPressed: onTap, child: const Text('Grant')),
      ),
    );
  }
}
