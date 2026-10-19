import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    final timezone =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezone),
    );

    const initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    final android =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    final canExact =
        await android?.canScheduleExactNotifications();

    debugPrint(
      "CAN SCHEDULE EXACT: $canExact",
    );
  }

  Future<void> scheduleMedicineCourse({
    required int baseId,
    required String title,
    required String body,
    required TimeOfDay time,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    int id = baseId;

    DateTime current = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    while (!current.isAfter(endDate)) {
      final scheduled = tz.TZDateTime(
        tz.local,
        current.year,
        current.month,
        current.day,
        time.hour,
        time.minute,
      );

      if (scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medicine_channel',
              'Medicine Reminders',
              channelDescription:
                  'Medication Reminder Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode:
              AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime,
        );

        debugPrint(
          "Scheduled Notification #$id at $scheduled",
        );
      }

      id++;
      current = current.add(
        const Duration(days: 1),
      );
    }

    final pending =
        await flutterLocalNotificationsPlugin
            .pendingNotificationRequests();

    debugPrint(
      "Pending Notifications: ${pending.length}",
    );
  }
}