import 'package:sporting_club/data/model/notifications_data.dart';
import 'ReponseListener.dart';

abstract class NotificationsResponseListener extends ResponseListener{

  void setNotifications(NotificationsData? data);
  void showImageNetworkError();
  void showSucessDelete();
  void showSucessDeleteAll();


}