import 'package:sporting_club/data/model/administratives_data.dart';
import 'ReponseListener.dart';

abstract class AddComplaintResponseListener extends ResponseListener{

  void setAdministratives(AdministrativesData? administrativesData);
  void showSuccess();


}