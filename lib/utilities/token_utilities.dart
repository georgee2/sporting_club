import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/home/home.dart';
// import 'package:sporting_club/ui/login/login.dart';
import 'local_settings.dart';

class TokenUtilities implements LoginResponseListener {
  LocalSettings _localSettings = LocalSettings();
  BuildContext? context;

  Future<void> refreshToken(BuildContext context) async {
    this.context = context;
    UserNetwork userNetwork = UserNetwork();
    await userNetwork.refreshToken(this);
  }

  @override
  void hideLoading() {
    // TODO: implement hideLoading
  }

  @override
  void showAuthError() {
    _localSettings.removeSession();
    // Navigator.pushAndRemoveUntil(
    //     context!,
    //     MaterialPageRoute(builder: (BuildContext context) => Login()),
    //     (Route<dynamic> route) => false);
  }

  @override
  void showGeneralError() {
    // TODO: implement showGeneralError
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void showNetworkError() {
    // TODO: implement showNetworkError
  }

  @override
  void showServerError(String? msg) {
    // TODO: implement showServerError
  }

  @override
  void showSuccessLogin(LoginData? data) {
    print('success refresh token');
    if (data?.token != null) {
      LocalSettings.token = "bearer " + (data?.token ?? "");
      _localSettings.setToken(data?.token ?? "");
      print('token: ' + (data?.token ?? ""));
    }
    if (data?.refresh_token != null) {
      _localSettings.setRefreshToken(data?.refresh_token ?? "");
      LocalSettings.refreshToken = data?.refresh_token ?? "";
    }

    Navigator.pushAndRemoveUntil(
        context!,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        (Route<dynamic> route) => false);
  }
}
