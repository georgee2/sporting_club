import 'package:sporting_club/data/model/login_data.dart';
import 'ReponseListener.dart';

abstract class RegisterMembershipListener extends ResponseListener{

  void showSuccessID(String? msg);
  void showSuccessMsgCode(String? msg);
  void showPhoneError(String? errorMsg);
  void showErrorMsg(String? errorMsg);
  void showEmailError({String? errorMsg});
  void showMemberShipIDError();

}