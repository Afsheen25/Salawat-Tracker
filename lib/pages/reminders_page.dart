import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
      await _saveReminderTime(picked);
      await scheduleDailyReminder(picked.hour, picked.minute);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${picked.format(context)}')),
      );
    }
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
  }

  Future<void> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');

    if (hour != null && minute != null) {
      final time = TimeOfDay(hour: hour, minute: minute);
      setState(() => selectedTime = time);
    }
  }

  Future<void> cancelReminder() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⏰ Daily Reminder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            selectedTime != null
                ? Text("Reminder set for: ${selectedTime!.format(context)}")
                : const Text("No reminder set yet."),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.notifications_active),
              label: const Text("Set Daily Reminder"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await cancelReminder();
                setState(() => selectedTime = null);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('reminder_hour');
                await prefs.remove('reminder_minute');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder cancelled')),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text("Cancel Reminder"),
            ),

          ],
        ),
      ),
    );
  }
}
