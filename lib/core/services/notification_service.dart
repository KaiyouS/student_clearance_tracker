import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  Future<void> showStepUpdate(String officeName, String status) async {
    // Web uses in-app banner via StudentProvider — skip here
    if (kIsWeb || !_initialized) return;

    final isSign   = status == 'signed';
    final title    = isSign ? '✅ Step Signed' : '⚠️ Step Flagged';
    final body     = isSign
        ? '$officeName has signed your clearance.'
        : '$officeName has flagged your clearance. Open the app for details.';

    await _plugin.show(
      id:    officeName.hashCode,
      title: title,
      body:  body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'clearance_channel',
          'Clearance Updates',
          channelDescription: 'Notifications for clearance step changes',
          importance: Importance.high,
          priority:   Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}