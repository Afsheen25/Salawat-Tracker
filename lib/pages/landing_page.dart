import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'info_page.dart';


class LandingPage extends StatelessWidget {
  const LandingPage ({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Salawat Tracker", style: TextStyle(fontSize: 28)),
            SizedBox(height: 16),
            Text("Build your habit of sending blessings daily."),
            SizedBox(height: 32),
            ElevatedButton(
              child: Text("Start"),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_first_time', false);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainPage()),
                  );
                },
            ),
            TextButton(
              child: Text("Learn More"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}