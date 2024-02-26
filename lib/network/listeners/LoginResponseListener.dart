import 'package:sporting_club/data/model/login_data.dart';
import 'ReponseListener.dart';

abstract class LoginResponseListener extends ResponseListener{

  void showSuccessLogin(LoginData? data);
}