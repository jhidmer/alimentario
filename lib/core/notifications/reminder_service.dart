import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static const _notificationId = 1001;
  static const _channelId = 'meal_reminders';
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Lima'));
    const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async => await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;

  Future<void> scheduleDaily(TimeOfDayValue time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      _notificationId,
      'Diario Alimentario',
      'Recuerda registrar tus comidas y cómo te sientes.',
      scheduled,
      const NotificationDetails(android: AndroidNotificationDetails(_channelId, 'Recordatorios de comidas', channelDescription: 'Recordatorios locales para registrar comidas', importance: Importance.defaultImportance)),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() => _plugin.cancel(_notificationId);
}

class TimeOfDayValue {
  const TimeOfDayValue({required this.hour, required this.minute});
  final int hour;
  final int minute;
}

final reminderService = ReminderService();
