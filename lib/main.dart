import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/locked_apps_provider.dart';
import 'screens/home_screen.dart';
import 'screens/permission_screen.dart';
import 'services/app_monitor_service.dart';
// Export the overlay entry point so it can be found by the plugin
export 'overlay_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the foreground task configuration
  final monitorService = AppMonitorService();
  await monitorService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LockedAppsProvider()),
      ],
      child: MaterialApp(
        title: 'Task Lock',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212), // Deep grey/black
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C2BEE), // Vibrant Purple
            secondary: Color(0xFF00B4D8), // Vibrant Blue
            surface: Color(0xFF1E1E1E),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF6C2BEE), // Purple FAB
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/permissions': (context) => const PermissionScreen(),
        },
      ),
    );
  }
}
