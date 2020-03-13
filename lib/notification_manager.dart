import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  final String appName;
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationManager({@required this.appName}) : assert(appName != null);

  Future<void> init() async {
    var initSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    var initSettings =
        InitializationSettings(initSettingsAndroid, initSettingsIOS);

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleDailyNotificationAt(Time time, int id) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '$appName daily channel id',
        '$appName\'s daily notifications',
        '$appName\'s daily notification');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _notificationsPlugin.showDailyAtTime(
        id,
        '$appName',
        'Have you made new job applications? Don\'t forget to add them here!',
        time,
        platformChannelSpecifics);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
