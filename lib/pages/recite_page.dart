import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:stracker/services/firestore_service.dart';
import 'package:stracker/providers/theme_provider.dart';

class RecitePage extends StatefulWidget {
  final Function()? onGoToGoals;

  const RecitePage({Key? key, this.onGoToGoals}) : super(key: key);

  @override
  State<RecitePage> createState() => _RecitePageState();
}

class _RecitePageState extends State<RecitePage> {
  final FirestoreService _firestore = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  int _sessionCount = 0;
  int _todayCount = 0;
  int _goal = 100;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAllData();
      });
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadTodayCount(),
      _loadGoal(),
    ]);
  }

  Future<void> _loadGoal() async {
    try {
      final goals = await _firestore.getGoals();
      if (mounted) {
        setState(() {
          _goal = goals['daily_goal'] ?? 100;
        });
      }
    } catch (e) {
      debugPrint("Error loading goal: $e");
    }
  }

  Future<void> _loadTodayCount() async {
    try {
      final count = await _firestore.getDailyCount(DateTime.now());
      if (mounted) {
        setState(() {
          _todayCount = count;
        });
      }
    } catch (e) {
      debugPrint("Error loading today's count: $e");
    }
  }

  void _incrementSession() {
    setState(() {
      _sessionCount++;
    });
  }

  Future<void> _addCountToToday() async {
    try {
      final newTotal = (_todayCount + _sessionCount).clamp(0, 9999);
      await _firestore.saveDailyCount(DateTime.now(), newTotal);
      if (mounted) {
        setState(() {
          _todayCount = newTotal;
          _sessionCount = 0;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to today's count!")),
      );
    } catch (e) {
      debugPrint("Error adding count: $e");
    }
  }

  Future<void> _resetAll() async {
    try {
      await _firestore.saveDailyCount(DateTime.now(), 0);
      if (mounted) {
        setState(() {
          _todayCount = 0;
          _sessionCount = 0;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Counts reset.")),
      );
    } catch (e) {
      debugPrint("Error resetting count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_todayCount / _goal).clamp(0, 1.0);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text("Recite"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
      ),
      body: GestureDetector(
        onTap: _incrementSession,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Tap anywhere to increase session count. Then press 'Add Count' to save your progress.",
                    style: TextStyle(color: colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 40,
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Today: $_todayCount / $_goal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Session: $_sessionCount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addCountToToday,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: Text(
                        "Add Count",
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _resetAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: Text(
                        "Reset",
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}