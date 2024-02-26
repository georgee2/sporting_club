import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';
import 'ReponseListener.dart';

abstract class UpdateMembershipListener extends ResponseListener{

  void showSuccess(String? msg);
  void showSecondStepSuccess(UserData? userData, bool? isUpdated, String? msg);
  void showPhoneError();
  void showEmailError();
  void showMemberShipIDError();
  void showError(String? error);

}