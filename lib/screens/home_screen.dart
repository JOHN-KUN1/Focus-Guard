import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../providers/task_provider.dart';
import '../providers/locked_apps_provider.dart';
import '../widgets/tasks_tab.dart';
import '../widgets/locked_apps_tab.dart';
import '../services/app_monitor_service.dart';
import 'add_task_dialog.dart';
import 'app_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedData = false;
  final AppMonitorService _monitorService = AppMonitorService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      context.read<TaskProvider>().loadTasks();
      context.read<LockedAppsProvider>().loadLockedApps();

      // Start the background monitoring service
      _monitorService.startMonitoring();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      // Add Task
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddTaskDialog(),
      );
    } else {
      // Add Locked App
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppPickerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // WithForegroundTask manages the foreground service lifecycle
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Lock'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'TASKS'),
              Tab(text: 'LOCKED APPS'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/permissions');
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [TasksTab(), LockedAppsTab()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
