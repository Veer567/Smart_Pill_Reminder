import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'firestore_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> initialize() async {
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Create notification channel for Android with default sound
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_reminder_channel',
      'Medicine Reminders',
      description: 'Channel for medicine reminder notifications',
      importance: Importance.max,
      playSound: true,
      sound: null, // Use default system sound
      enableVibration: true,
      showBadge: true,
    );

    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);
    print('Notification channel created: medicine_reminder_channel');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification tapped: ${details.payload}");
      },
    );
    print('NotificationService initialized');
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'medicine_reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Channel for medicine reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: null, // Use default system sound
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test to verify notification setup.',
      platformChannelSpecifics,
    );
    print('Test notification triggered');
  }

  static Future<void> scheduleDailyNotification({
    required String docId,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    // Calculate the scheduled time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time is in the past today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'medicine_reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Channel for medicine reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: null, // Use default system sound
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Cancel any existing notification with the same ID to avoid duplicates
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      docId.hashCode, // Unique ID for the notification
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // For Android 13
      matchDateTimeComponents: DateTimeComponents.time, // Daily recurrence
    );
    print('Scheduled notification for $title at ${time.format} with ID $docId');
  }

  static Future<void> cancelNotification(String docId) async {
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode);
    print('Canceled notification with ID $docId');
  }

  static Future<void> checkPendingNotifications() async {
    final pendingNotifications = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    print('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print(
        'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}',
      );
    }
  }

  static Future<void> rescheduleAllNotifications() async {
    final service = FirestoreService();
    final medicines = await service.getMedicines();
    for (var medicine in medicines) {
      final timeStr = medicine['time'];
      if (timeStr != null) {
        try {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1].replaceAll(RegExp(r'[^\d]'), ''));
            final time = TimeOfDay(hour: hour, minute: minute);
            await scheduleDailyNotification(
              docId: medicine['docId'],
              title: 'Time to take your medicine!',
              body:
                  'It\'s time to take your ${medicine['name']}. Don\'t forget your dose!',
              time: time,
            );
          }
        } catch (e) {
          print('Error rescheduling notification for ${medicine['name']}: $e');
        }
      }
    }
    print('All notifications rescheduled');
  }
}
