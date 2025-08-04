import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  tz.initializeTimeZones(); // Needed for scheduling
}

Future<void> scheduleDailyReminder(int hour, int minute) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Time to Send Salawat',
    'Recite Salawat upon the Prophet ﷺ',
    tz.TZDateTime.local(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      minute,
    ).add(const Duration(days: 1)), // schedule for next day
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'salawat_channel',
        'Salawat Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
  );
}
