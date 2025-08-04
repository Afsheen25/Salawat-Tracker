// pages/info_page.dart
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Learn More')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Send Salawat?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Salawat (peace and blessings upon the Prophet ﷺ) brings barakah, calms the heart, and draws you closer to Allah.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'How this App Helps:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Track your daily progress\n• Set gentle reminders\n• Build a lifelong habit, quietly'),
            Spacer(),
            Center(
              child: ElevatedButton(
                child: Text("Let's Begin"),
                onPressed: () {
                  Navigator.pop(context); // or Navigator.push to MainPage
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
