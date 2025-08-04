import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/recite_page.dart';
import 'pages/progress_page.dart';
import 'pages/reminders_page.dart';
import 'pages/my_page.dart';
import 'pages/my_goals.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ✅ Initialize local notifications (your version)
  await initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SalawatApp(),
    ),
  );
}


class SalawatApp extends StatelessWidget {
  const SalawatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // 🌞 Light ColorScheme
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2C6E49), // Dark Green
      onPrimary: Colors.white,
      secondary: Color(0xFF4C956C), // Mid Green
      onSecondary: Colors.white,
      background: Color(0xFFFFFFFF), // Light Cream
      onBackground: Colors.black,
      surface: Color(0xFFFFFFFF),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    );

    // 🌙 Dark ColorScheme
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF35A166),
      onPrimary: Colors.white,
      secondary: Color(0xFF35A166),
      onSecondary: Colors.white,
      background: Color(0xFF121212),
      onBackground: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.black,
    );

    // 🌞 Light Theme
    final lightTheme = ThemeData.from(
      colorScheme: lightColorScheme,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: lightColorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.secondary,
          foregroundColor: lightColorScheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColorScheme.background,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );

    // 🌙 Dark Theme
    // 🌙 Dark ColorScheme
// 🌙 Dark Theme
    final darkTheme = ThemeData.from(
      colorScheme: darkColorScheme,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: darkColorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.secondary,
          foregroundColor: darkColorScheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: darkColorScheme.primary.withOpacity(0.2),
          elevation: 2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColorScheme.background,
        selectedItemColor: darkColorScheme.secondary,
        unselectedItemColor: Colors.grey.shade500,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
      ),
    );

    return MaterialApp(
      title: 'Salawat Tracker',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

// 🧭 Main Navigation Page
class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecitePage(onGoToGoals: () => _onItemTapped(3)),
      ProgressPage(),
      RemindersPage(),
      MyGoalsPage(),
      MyPage(onGoToGoals: () => _onItemTapped(3)),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high),
            label: 'Recite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
        ],
      ),
    );
  }
}
