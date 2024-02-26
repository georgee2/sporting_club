import 'ReponseListener.dart';

abstract class BasicResponseListener extends ResponseListener{

  void showSuccess(String? error);
  void showLoginError(String? error);

}