import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:stracker/pages/splash_screen.dart';
import 'package:stracker/providers/theme_provider.dart';

class MyPage extends StatelessWidget {
  final VoidCallback? onGoToGoals;

  const MyPage({Key? key, this.onGoToGoals}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
      );
    }
  }

  String _extractUsername(String? email) {
    if (email == null) return "User";
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "No user found. Please login again.",
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final email = user.email;
    final username = _extractUsername(email);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            color: colorScheme.secondary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(
              Icons.dark_mode,
              color: colorScheme.primary,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          ListTile(
            leading: Icon(
              Icons.flag,
              color: colorScheme.primary,
            ),
            title: const Text("Set Goals"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (onGoToGoals != null) {
                onGoToGoals!();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.primary,
            ),
            title: const Text("Logout"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}