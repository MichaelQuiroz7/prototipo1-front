import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Future<void> openExactAlarmSettings() async {
  //   const intentUri = 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM';
  //   await launchUrl(Uri.parse(intentUri), mode: LaunchMode.externalApplication);
  // }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    // Inicializa las zonas horarias
    initializeTimeZones();

    // Lista de time zones:
    // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    setLocalLocation(getLocation('America/Guayaquil'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // const DarwinInitializationSettings iosSettings =
    //     DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
    required DateTime startDate,
    required ReminderFrequency frequency,
  }) async {
    // 🔔 INMEDIATA → SHOW
    if (frequency == ReminderFrequency.instant) {
      await showInstantNotification(id: id, title: title, body: body ?? '');
      return;
    }

    final TZDateTime baseDate = TZDateTime.from(startDate, local);

    // ⏱ PROGRAMADAS
    Duration delay;

    switch (frequency) {
      case ReminderFrequency.every5Minutes:
        delay = const Duration(minutes: 5);
        break;
      case ReminderFrequency.every30Minutes:
        delay = const Duration(minutes: 30);
        break;
      default:
        delay = Duration.zero;
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      baseDate.add(delay),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dynamic_reminder_channel',
          'Dynamic Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailyAtHour({
    required int id,
    required String title,
    String? body,
    required int hour, // 7, 13, 20
  }) async {
    // Hora actual en zona local
    final now = TZDateTime.now(local);

    // Fecha/hora objetivo HOY
    TZDateTime scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    // Si ya pasó esa hora hoy → mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_fixed_hour_channel',
          'Daily Fixed Hour Notifications',
          channelDescription: 'Notificaciones diarias a hora fija',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyAtTime({
    required int id,
    required String title,
    String? body,
    required int hour,
    required int minute,
  }) async {
    final now = TZDateTime.now(local);

    TZDateTime scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_fixed_time_channel',
          'Daily Fixed Time Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleBeforeAndOnDate({
    required int baseId,
    required String title,
    String? body,
    required DateTime targetDate, // ej: 2026-01-06
    required int hour, // 0–23
    required int minute, // 0–59
  }) async {
    final now = TZDateTime.now(local);

    // ============================
    // Día anterior
    // ============================
    TZDateTime dayBefore = TZDateTime(
      local,
      targetDate.year,
      targetDate.month,
      targetDate.day - 1,
      hour,
      minute,
    );

    // ============================
    // Mismo día
    // ============================
    TZDateTime sameDay = TZDateTime(
      local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );

    // 🔔 Notificación día anterior
    if (dayBefore.isAfter(now)) {
      await notificationsPlugin.zonedSchedule(
        baseId,
        title,
        body ?? '📅 Tu cita es mañana',
        dayBefore,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminder_channel',
            'Appointment Reminders',
            channelDescription: 'Recordatorios de citas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
      );
    }

    // 🔔 Notificación mismo día
    if (sameDay.isAfter(now)) {
      await notificationsPlugin.zonedSchedule(
        baseId + 1,
        title,
        body ?? '📅 Tu cita es hoy',
        sameDay,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminder_channel',
            'Appointment Reminders',
            channelDescription: 'Recordatorios de citas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
      );
    }
  }

  static Future<void> cancel(int id) async {
    await notificationsPlugin.cancel(id);
  }
}

enum ReminderFrequency { instant, every5Minutes, every30Minutes, daily, weekly }
