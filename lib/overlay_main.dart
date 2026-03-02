import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entry point for the overlay
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force full screen (immersiveSticky is more aggressive)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C2BEE),
          brightness: Brightness.dark,
        ),
      ),
      home: const PolishedOverlayScreen(),
    );
  }
}

class PolishedOverlayScreen extends StatefulWidget {
  const PolishedOverlayScreen({super.key});

  @override
  State<PolishedOverlayScreen> createState() => _PolishedOverlayScreenState();
}

class _PolishedOverlayScreenState extends State<PolishedOverlayScreen> {
  Future<void> _snoozeAndClose() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Snooze for 15 seconds
      final int snoozeUntil = DateTime.now().millisecondsSinceEpoch + 15000;
      await prefs.setInt('overlay_snooze_until', snoozeUntil);

      await FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      // Close anyway
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Maintain immersiveSticky and transparency on rebuilds
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with subtle glow effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C2BEE).withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Main Title
              const Text(
                'Focus Time',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'This app is currently locked to keep you focused on your goals. If you have completed the task navigate to the task lock app and mark them as done to gain access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 64),
              // Polished Button
              ElevatedButton.icon(
                onPressed: _snoozeAndClose,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back (15s)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF302B63),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
