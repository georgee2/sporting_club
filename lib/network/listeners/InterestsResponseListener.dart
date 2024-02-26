import 'package:sporting_club/data/model/interests_data.dart';
import 'ReponseListener.dart';

abstract class InterestsResponseListener extends ResponseListener{

  void setInterests(InterestsData? data);

  void showUpdateSuccess();

}