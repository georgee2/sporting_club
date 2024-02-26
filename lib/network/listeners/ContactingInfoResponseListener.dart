import 'package:sporting_club/data/model/contacting_info_data.dart';
import 'ReponseListener.dart';

abstract class ContactingInfoResponseListener extends ResponseListener {
  void setData(ContactingInfoData? data);

  void showImageNetworkError();
}
