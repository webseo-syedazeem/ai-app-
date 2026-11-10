import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {}
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required DateTime when,
  }) async {
    if (kIsWeb || !_initialized) return;
    if (when.isBefore(DateTime.now())) return;
    try {
      final scheduled = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        id,
        'AI Daily Helper Reminder',
        title,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Scheduled reminders and briefings',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }
}
