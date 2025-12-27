import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:typed_data';
import '../main.dart';
import '../screens/custom_notification_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/activity_cubit.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Store notification details for custom dialog
  static Map<int, Map<String, dynamic>> _notificationData = {};

  Future<void> initNotifications() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    await _requestPermissions();
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final id = response.id;
    if (id != null && _notificationData.containsKey(id)) {
      final data = _notificationData[id]!;

      // Mark notification as triggered in cubit
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<ActivityCubit>().markNotificationTriggered(id);
      }

      _showCustomDialog(
        title: data['title'],
        body: data['body'],
        eventTime: data['eventTime'],
      );
    }
  }

  // Show custom dialog in the middle of screen
  void _showCustomDialog({
    required String title,
    required String body,
    required DateTime eventTime,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomNotificationDialog(
          title: title,
          body: body,
          eventTime: eventTime,
        ),
      );
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // SCHEDULE NOTIFICATION 10 MIN BEFORE EVENT
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime eventTime,
  }) async {
    // Store notification data for custom dialog
    _notificationData[id] = {
      'title': title,
      'body': body,
      'eventTime': eventTime,
    };

    final tz.TZDateTime tzEventTime = tz.TZDateTime.from(
      eventTime,
      tz.local,
    ).subtract(const Duration(minutes: 10));

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzEventTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_channel',
          'Activity Notifications',
          channelDescription: 'Notifications for activities',
          importance: Importance.high,
          priority: Priority.high,

          // Professional styling
          color: const Color(0xFFFF5100),
          colorized: false,

          // Sound & Vibration
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 300, 100, 300]),

          // Icon
          icon: '@mipmap/ic_launcher',

          // Text Display
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Tap to view details',
          ),

          // Timing
          showWhen: true,
          when: eventTime.millisecondsSinceEpoch,

          // Display Settings
          channelShowBadge: true,
          autoCancel: true,
          ongoing: false,
          visibility: NotificationVisibility.public,
          ticker: title,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }
}
