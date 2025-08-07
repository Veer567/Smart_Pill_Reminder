import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
      home: const SplashScreen(),
    );
  }
}
