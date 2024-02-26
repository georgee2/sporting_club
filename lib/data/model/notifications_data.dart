import 'notification.dart';

class NotificationsData {
  final List<NotificationModel>? notifications;

  NotificationsData({this.notifications});

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    List<NotificationModel> notificationsList = [];
    if (json['notifications'] != null) {
      var list = json['notifications'] as List;
      if (list != null) {
        notificationsList = list.map((i) => NotificationModel.fromJson(i)).toList();
      }
    }

    return NotificationsData(
      notifications: json['notifications'] == null ? null : notificationsList,
    );
  }
}
