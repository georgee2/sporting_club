import 'package:sporting_club/data/model/emergency_data.dart';
import 'ReponseListener.dart';

abstract class MoreResponseListener extends ResponseListener{

  void setData(EmergencyData? data);

  void showLogoutSuccess();

}