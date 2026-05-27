import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:meteo_garden/main.dart';
import 'package:meteo_garden/models/url.dart';
import 'package:meteo_garden/screens/home_shell.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _listenersInitialized = false;
  static bool _tokenRefreshListenerInitialized = false;

  static Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permís notificacions: ${settings.authorizationStatus}');
  }

  static Future<void> initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings: settings);
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'meteogarden_channel',
      'MeteoGarden Notifications',
      channelDescription: 'Notificacions de MeteoGarden',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'MeteoGarden',
      body: message.notification?.body ?? '',
      notificationDetails: details,
    );
  }

  static Future<void> sendTokenToBackend(String userToken) async {
    await requestPermission();
    await initLocalNotifications();

    final fcmToken = await _messaging.getToken();

    if (fcmToken == null) {
      debugPrint('No s’ha pogut obtenir el FCM token');
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/save-token/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $userToken',
      },
      body: jsonEncode({'token': fcmToken}),
    );

    debugPrint('FCM Token: $fcmToken');
    debugPrint('Resposta registre FCM: ${response.statusCode}');
    debugPrint('Body registre FCM: ${response.body}');

    await initListeners();
    listenTokenRefresh(userToken);
  }

  static Future<void> deleteTokenFromBackend(String userToken) async {
    final fcmToken = await _messaging.getToken();

    if (fcmToken == null) {
      debugPrint('No s’ha pogut obtenir el FCM token per eliminar-lo');
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/delete-token/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $userToken',
      },
      body: jsonEncode({'token': fcmToken}),
    );

    debugPrint('Resposta eliminar FCM: ${response.statusCode}');
    debugPrint('Body eliminar FCM: ${response.body}');
  }

  static Future<void> initListeners() async {
    if (_listenersInitialized) return;

    listenForegroundNotifications();
    listenNotificationClicks();
    await checkInitialNotification();

    _listenersInitialized = true;
  }

  static void listenForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificació rebuda en foreground');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      showLocalNotification(message);
    });
  }

  static void listenNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Usuari ha clicat una notificació');
      debugPrint('Data: ${message.data}');

      _goToHomeFromNotification();
    });
  }

  static Future<void> checkInitialNotification() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App oberta des d’una notificació');
      debugPrint('Data: ${initialMessage.data}');

      _goToHomeFromNotification();
    }
  }

  static void listenTokenRefresh(String userToken) {
    if (_tokenRefreshListenerInitialized) return;

    FirebaseMessaging.instance.onTokenRefresh.listen((newFcmToken) async {
      debugPrint('Nou FCM token: $newFcmToken');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/save-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $userToken',
        },
        body: jsonEncode({'token': newFcmToken}),
      );

      debugPrint('Resposta refresh FCM: ${response.statusCode}');
      debugPrint('Body refresh FCM: ${response.body}');
    });

    _tokenRefreshListenerInitialized = true;
  }

  static void _goToHomeFromNotification() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }
}
