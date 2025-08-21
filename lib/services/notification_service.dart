// notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String _takenPayload = 'mark_as_taken';
const String _missedDosePayload = 'missed_dose_alert';
const String _refillPayload = 'refill_reminder';

class NotificationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print('NotificationService already initialized');
      return;
    }

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_reminder_channel',
      'Medicine Reminders',
      description: 'Channel for medicine reminder notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidNotificationChannel refillChannel = AndroidNotificationChannel(
      'refill_channel',
      'Refill Reminders',
      description: 'Channel for medicine refill notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Channel for medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap(
          '@drawable/ic_launcher_foreground',
        ), // large icon
        largeIcon: DrawableResourceAndroidBitmap(
          '@drawable/ic_launcher_foreground',
        ),
      ),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('snooze_10', 'Snooze 10m'),
        const AndroidNotificationAction('snooze_15', 'Snooze 15m'),
        const AndroidNotificationAction(_takenPayload, 'Mark as Taken'),
      ],
    );

    print('NotificationService initialized');
    _isInitialized = true;
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
    required String name,
    required List<TimeOfDay> times,
    required int stock,
    required int dosesPerDay,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found. Skipping notification scheduling.');
      return;
    }

    await cancelNotification(docId);

    for (var time in times) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final notificationId = '${user.uid}_$docId${time.hashCode}'.hashCode;

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'medicine_reminder_channel',
        'Medicine Reminders',
        channelDescription: 'Channel for medicine reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction('snooze_10', 'Snooze 10m'),
          const AndroidNotificationAction('snooze_15', 'Snooze 15m'),
          const AndroidNotificationAction(_takenPayload, 'Mark as Taken'),
        ],
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Time for your $name',
        'It\'s time to take your dose. Don\'t forget!',
        tzScheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '$_takenPayload\_$docId',
      );

      print(
        'Scheduled notification for $name at ${time.hour}:${time.minute} with ID $notificationId',
      );

      final missedDoseScheduledTime = tzScheduledDate.add(
        const Duration(minutes: 30),
      );
      final missedDoseId = 'missed_$notificationId'.hashCode;
      await flutterLocalNotificationsPlugin.zonedSchedule(
        missedDoseId,
        'Missed $name dose?',
        'It looks like you haven\'t marked your medicine as taken.',
        missedDoseScheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminder_channel',
            'Medicine Reminders',
            channelDescription: 'Channel for medicine reminder notifications',
            ongoing: false,
            autoCancel: true,
            actions: const <AndroidNotificationAction>[],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$_missedDosePayload$docId',
      );
    }

    await scheduleRefillNotification(
      docId: docId,
      name: name,
      stock: stock,
      dosesPerDay: dosesPerDay,
    );
  }

  static Future<void> scheduleRefillNotification({
    required String docId,
    required String name,
    required int stock,
    required int dosesPerDay,
  }) async {
    if (stock <= 5 && stock > 0) {
      final now = tz.TZDateTime.now(tz.local);
      // Add a 1-second buffer to ensure the date is in the future
      final refillDate = now.add(const Duration(seconds: 1));

      final refillId = 'refill_$docId'.hashCode;

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'refill_channel',
        'Refill Reminders',
        channelDescription: 'Channel for medicine refill notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.cancel(refillId);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        refillId,
        'Refill Reminder: $name',
        'You have only $stock pills of $name left. Time to refill!',
        refillDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$_refillPayload$docId',
      );
      print(
        'Scheduled refill notification for $name on $refillDate because stock is low.',
      );
    }
  }

  static Future<void> markAsTaken(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found. Skipping mark as taken.');
      return;
    }

    // Fetch the medicine data
    final medicines = await FirestoreService().getMedicines();
    final medicine = medicines.firstWhere(
      (med) => med['docId'] == docId,
      orElse: () => {},
    );

    if (medicine.isEmpty) {
      print('Medicine not found for docId: $docId');
      return;
    }

    // Cancel existing notifications
    final times = medicine['times'] as List<dynamic>? ?? [];
    for (var time in times) {
      final timeParts = (time as String).split(':');
      final timeOfDay = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      final notificationId = '${user.uid}_$docId${timeOfDay.hashCode}'.hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      await flutterLocalNotificationsPlugin.cancel(
        'missed_$notificationId'.hashCode,
      );
    }
    await flutterLocalNotificationsPlugin.cancel('refill_$docId'.hashCode);

    // Decrement stock
    await FirestoreService().decrementStock(docId);

    // Fetch updated medicine data to get the new stock value
    final updatedMedicines = await FirestoreService().getMedicines();
    final updatedMedicine = updatedMedicines.firstWhere(
      (med) => med['docId'] == docId,
      orElse: () => {},
    );

    if (updatedMedicine.isNotEmpty) {
      final newStock = updatedMedicine['stock'] ?? 0;
      final name = updatedMedicine['name'] ?? 'Your Medicine';
      final dosesPerDay = updatedMedicine['dosesPerDay'] ?? 1;

      // Schedule a refill notification if stock is low
      await scheduleRefillNotification(
        docId: docId,
        name: name,
        stock: newStock,
        dosesPerDay: dosesPerDay,
      );
    }
  }

  static Future<void> snoozeNotification({
    required String docId,
    required int minutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found. Skipping notification snoozing.');
      return;
    }

    // Fetch the medicine name from Firestore
    final medicines = await FirestoreService().getMedicines();
    final medicine = medicines.firstWhere(
      (med) => med['docId'] == docId,
      orElse: () => {},
    );

    if (medicine.isEmpty) {
      print('Medicine not found for docId: $docId');
      return;
    }
    final medicineName = medicine['name'] ?? 'Your Medicine';

    final now = tz.TZDateTime.now(tz.local);
    final snoozedTime = now.add(Duration(minutes: minutes));

    final notificationId = '${user.uid}_$docId'.hashCode;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Channel for medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('snooze_10', 'Snooze 10m'),
        const AndroidNotificationAction('snooze_15', 'Snooze 15m'),
        const AndroidNotificationAction(_takenPayload, 'Mark as Taken'),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.cancel(notificationId);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Snoozed Reminder: $medicineName',
      'Your reminder is snoozed. It will reappear in $minutes minutes.',
      snoozedTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'snooze_$minutes$docId',
    );
    print('Snoozed notification for docId: $docId for $minutes minutes');
  }

  static Future<void> cancelNotification(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found. Skipping notification cancellation.');
      return;
    }

    final medicines = await FirestoreService().getMedicines();
    final medicine = medicines.firstWhere(
      (med) => med['docId'] == docId,
      orElse: () => {},
    );
    if (medicine.isNotEmpty) {
      final times = medicine['times'] as List<dynamic>? ?? [];
      for (var time in times) {
        final timeParts = (time as String).split(':');
        final timeOfDay = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        final notificationId =
            '${user.uid}_$docId${timeOfDay.hashCode}'.hashCode;
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        await flutterLocalNotificationsPlugin.cancel(
          'missed_$notificationId'.hashCode,
        );
      }
      await flutterLocalNotificationsPlugin.cancel('refill_$docId'.hashCode);
    }
    print('Canceled all notifications for docId: $docId');
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found. Skipping rescheduling.');
      return;
    }

    for (var medicine in medicines) {
      final times = medicine['times'] as List<dynamic>?;
      if (times != null && times.isNotEmpty) {
        try {
          final selectedTimes = times.map((e) {
            final parts = (e as String).split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList();
          await scheduleDailyNotification(
            docId: medicine['docId'],
            name: medicine['name'] ?? 'Your Medicine',
            times: selectedTimes,
            stock: medicine['stock'] ?? 0,
            dosesPerDay: medicine['dosesPerDay'] ?? 1,
          );
        } catch (e) {
          print('Error rescheduling notification for ${medicine['name']}: $e');
        }
      }
    }
    print('All notifications rescheduled for user ${user.uid}');
  }
}
