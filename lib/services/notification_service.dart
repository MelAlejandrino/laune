import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap logic here if needed
      },
    );

    _initialized = true;
  }

  Future<bool> _ensurePermissions() async {
    if (kIsWeb) return false;

    // Android 13+ requires runtime notification permission.
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      // Android 12+ restricts exact alarms behind user-controlled settings.
      // We request it here so exact scheduling can work when the OS allows it.
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (_) {
        // If the plugin/OS doesn't support requesting exact alarms, we'll
        // still handle fallback scheduling in scheduleDailyReminder().
      }
      return granted ?? false;
    }

    // iOS can request permissions explicitly as well.
    final iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // macOS can request permissions explicitly as well.
    final macPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    if (macPlugin != null) {
      final granted = await macPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Other platforms (e.g. Windows/Linux) may not require explicit permission here.
    return true;
  }

  Future<bool> scheduleDailyReminder(TimeOfDay time) async {
    await init();
    final permitted = await _ensurePermissions();
    if (!permitted) return false;

    await _notificationsPlugin.cancelAll(); // Clear previous schedules

    // Avoid custom tz.local IDs: the plugin forwards the zone name to the
    // platform and expects a real IANA timezone. Instead, compute the next
    // desired local clock time in Dart, convert it to UTC, then schedule using
    // tz.UTC.
    final nowLocal = DateTime.now();
    var desiredLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      time.hour,
      time.minute,
    );
    if (desiredLocal.isBefore(nowLocal)) {
      desiredLocal = desiredLocal.add(const Duration(days: 1));
    }
    final desiredUtc = desiredLocal.toUtc();
    final scheduledDate = tz.TZDateTime(
      tz.UTC,
      desiredUtc.year,
      desiredUtc.month,
      desiredUtc.day,
      desiredUtc.hour,
      desiredUtc.minute,
    );

    Future<void> scheduleAndroid({required AndroidScheduleMode mode}) async {
      await _notificationsPlugin.zonedSchedule(
        0,
        'Time for a reflection',
        'Take a moment to capture how you are feeling.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Time for your daily mood reflection',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    try {
      await scheduleAndroid(mode: AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      // Android 12+ may block exact alarms unless the user allows it in settings.
      if (e.code == 'exact_alarms_not_permitted') {
        await scheduleAndroid(mode: AndroidScheduleMode.inexactAllowWhileIdle);
      } else {
        rethrow;
      }
    }

    return true;
  }

  Future<void> cancelAll() async {
    await init();
    await _notificationsPlugin.cancelAll();
  }
}
