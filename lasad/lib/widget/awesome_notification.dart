import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:lasad/widget/theme_color/color.dart';

class MyNotificationService {
  static Future<void> init() async {
    AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'my_topic_channel_id',
          channelName: 'My Topic Channel Name',
          channelDescription: 'Channel for news notifications',
          defaultColor: lightTeal,
          ledColor: lightTeal,
        ),
      ],
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'my_topic_channel_id',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {'payload': payload},
      ),
    );
  }
}
