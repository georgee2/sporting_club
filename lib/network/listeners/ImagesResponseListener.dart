import 'package:sporting_club/data/model/images_list_data.dart';

import 'ReponseListener.dart';

abstract class ImagesResponseListener extends ResponseListener{

  void showSuccess(ImagesListData? data);
  void showLoginError(String? error);

}