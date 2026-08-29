import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/reminder_scheduler.dart';

/// Penjadwal pengingat memakai notifikasi lokal perangkat.
///
/// Sengaja lokal, bukan push: pengingat harian tidak butuh server, tidak butuh
/// kredensial, dan tetap bekerja tanpa koneksi.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Id tetap agar penjadwalan berikutnya menggantikan yang lama, bukan menumpuk.
  static const notificationId = 1001;
  static const _channelId = 'dilsensei_daily_reminder';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Izin diminta saat pengguna menyalakan pengingat, bukan saat app
          // pertama dibuka, supaya permintaannya punya konteks.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    _isInitialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        return await android?.requestNotificationsPermission() ?? false;
      }

      final darwin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      return await darwin?.requestPermissions(alert: true, sound: true) ??
          false;
    } on Object catch (error) {
      debugPrint('PENGINGAT: gagal meminta izin notifikasi: $error');
      return false;
    }
  }

  @override
  Future<void> schedule(ReminderContent content) async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Daily reminder',
        channelDescription: 'Reminds you to keep your practice streak',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: content.title,
      body: content.body,
      scheduledDate: tz.TZDateTime.from(content.scheduledFor, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Diulang tiap hari pada jam yang sama; isinya disegarkan tiap app dibuka.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(id: notificationId);
  }
}
