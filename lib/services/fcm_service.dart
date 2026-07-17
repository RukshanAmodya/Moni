import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions (specifically for iOS and Android 13+)
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Fetch token for targeted pushes
    try {
      final token = await _messaging.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('Error getting FCM token: $e');
    }

    // Handle messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification: ${message.notification?.title}');
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
    });
  }
}
