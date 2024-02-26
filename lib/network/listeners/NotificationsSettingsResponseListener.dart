import 'package:sporting_club/data/model/interests_data.dart';

import 'ReponseListener.dart';

abstract class NotificationsSettingsResponseListener extends ResponseListener {
  void showChangeStatusSuccess();

  void showChangeSoundSuccess();
  void setInterests(InterestsData? interestsData);
  void showUpdateSuccess();
  void showImageNetworkError();
}
