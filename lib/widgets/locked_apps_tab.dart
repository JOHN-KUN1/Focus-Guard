import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locked_apps_provider.dart';

class LockedAppsTab extends StatelessWidget {
  const LockedAppsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LockedAppsProvider>(
      builder: (context, provider, child) {
        if (provider.lockedApps.isEmpty) {
          return const Center(
            child: Text(
              'No apps locked.\nTap + to lock an app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.lockedApps.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final app = provider.lockedApps[index];
            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white12,
                  child: Icon(
                    Icons.android,
                    color: Colors.white70,
                  ), // Placeholder for icon
                ),
                title: Text(
                  app.appName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  app.packageName,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.redAccent),
                  onPressed: () => provider.removeLockedApp(app.packageName),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
