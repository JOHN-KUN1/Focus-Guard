import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:provider/provider.dart';
import '../providers/locked_apps_provider.dart';
import '../models/locked_app.dart';

class AppPickerScreen extends StatefulWidget {
  const AppPickerScreen({super.key});

  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends State<AppPickerScreen> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    // Exclude system apps
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      withIcon: true,
    );
    // Sort
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (mounted) {
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
    }
  }

  void _filterApps(String query) {
    setState(() {
      _filteredApps = _apps.where((app) {
        return app.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _filterApps,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search apps...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredApps.length,
              itemBuilder: (context, index) {
                final app = _filteredApps[index];
                return Consumer<LockedAppsProvider>(
                  builder: (context, provider, _) {
                    final isLocked = provider.lockedApps.any(
                      (a) => a.packageName == app.packageName,
                    );

                    return ListTile(
                      leading: app.icon != null
                          ? Image.memory(app.icon!, width: 40, height: 40)
                          : const Icon(Icons.android, color: Colors.white70),
                      title: Text(
                        app.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Switch(
                        value: isLocked,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) {
                          if (val) {
                            provider.addLockedApp(
                              LockedApp(
                                packageName: app.packageName,
                                appName: app.name,
                              ),
                            );
                          } else {
                            provider.removeLockedApp(app.packageName);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
