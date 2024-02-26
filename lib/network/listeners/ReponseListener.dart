

abstract class ResponseListener{

  void showLoading();
  void hideLoading();
  void showNetworkError();
  void showGeneralError();
  void showServerError(String? msg);
  void showAuthError();

}