import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/auth_wrapper.dart';

// A top-level function to handle foreground notification actions
@pragma('vm:entry-point')
void notificationTapForegroundHandler(
  NotificationResponse notificationResponse,
) async {
  print('notificationTapForegroundHandler: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    final parts = notificationResponse.payload!.split('_');
    final docId = parts.last;
    if (notificationResponse.payload!.contains('snooze_10')) {
      await NotificationService.snoozeNotification(docId: docId, minutes: 10);
    } else if (notificationResponse.payload!.contains('snooze_15')) {
      await NotificationService.snoozeNotification(docId: docId, minutes: 15);
    } else if (notificationResponse.payload!.contains('mark_as_taken')) {
      await NotificationService.markAsTaken(docId);
    }
  }
}

// A top-level function to handle background notification actions
@pragma('vm:entry-point')
Future<void> notificationTapBackgroundHandler(
  NotificationResponse notificationResponse,
) async {
  print('notificationTapBackgroundHandler: ${notificationResponse.payload}');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  if (notificationResponse.payload != null) {
    final parts = notificationResponse.payload!.split('_');
    final docId = parts.last;
    if (notificationResponse.payload!.contains('snooze_10')) {
      await NotificationService.snoozeNotification(docId: docId, minutes: 10);
    } else if (notificationResponse.payload!.contains('snooze_15')) {
      await NotificationService.snoozeNotification(docId: docId, minutes: 15);
    } else if (notificationResponse.payload!.contains('mark_as_taken')) {
      await NotificationService.markAsTaken(docId);
    }
  }
}

Future<void> requestNotificationPermission(BuildContext context) async {
  print("Requesting notification permission...");
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    print("Permission not granted, requesting...");
    final result = await Permission.notification.request();
    if (!result.isGranted) {
      print("Permission denied, showing dialog...");
      await showPermissionDeniedDialog(context);
    }
  }
  print("Permission status: ${await Permission.notification.status}");
}

Future<void> showPermissionDeniedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Notifications Disabled'),
      content: const Text(
        'To receive medicine reminders, please enable notifications in your app settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}

Future<void> requestIgnoreBatteryOptimizations() async {
  try {
    const platform = MethodChannel('com.example.medicine/battery_optimization');
    final result = await platform.invokeMethod(
      'requestIgnoreBatteryOptimizations',
    );
    print("Battery optimization request result: $result");
  } on PlatformException catch (e) {
    print("Failed to request battery optimization: ${e.message}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationTapForegroundHandler,
    onDidReceiveBackgroundNotificationResponse:
        notificationTapBackgroundHandler,
  );

  print("Initializing NotificationService...");
  await NotificationService.initialize();

  try {
    print("Rescheduling notifications...");
    await NotificationService.rescheduleAllNotifications();
    print("Rescheduling completed.");
    print("Showing test notification...");
    await NotificationService.showTestNotification();
  } catch (e) {
    print("Error during notification setup: $e");
  }

  print("Requesting battery optimization...");
  await requestIgnoreBatteryOptimizations();

  runApp(const SmartMedicineApp());
}

class SmartMedicineApp extends StatelessWidget {
  const SmartMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Requesting notification permission...");
      await requestNotificationPermission(context);
    });

    return MaterialApp(
      title: 'Smart Medicine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthWrapper(), // 👈 directly goes to AuthWrapper
    );
  }
}
