import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user_update_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/InterestsResponseListener.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/listeners/UpdateMembershipListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';

import '../api_urls.dart';
import 'notifications_network.dart';

class UserNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  loginUser(String userMembership, bool send_phone, bool send_email,
      BasicResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
      "send_phone": send_phone ? "yes" : "no",
      "send_email": send_email ? "yes" : "no",
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.LOGIN;
    print(url);
    try {
      final response = await http
          .post(Uri.parse(ApiUrls.MAIN_URL + ApiUrls.LOGIN), body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccess(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showLoginError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  loginMessageUser(String userMembership, bool send_phone, bool send_email,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
      "send_phone": send_phone ? "yes" : "no",
      "send_email": send_email ? "yes" : "no",
    };
    print(parameters.toString());
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.REQUIST_CODE_MESSAGE),
          body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccessMsgCode(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
          loginResponseListener.showAuthError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  verifyLogin(String userMembership, String code,
      LoginResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
      "verification_code": code
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.VERIFY;
    print(url);
    try {
      final response = await http.post(Uri.parse(url), body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<LoginData> baseResponse =
            BaseResponse<LoginData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          NotificationsNetwork notificationsNetwork = NotificationsNetwork();
          await notificationsNetwork.subscribeNotification(
              baseResponse.data ?? LoginData(), loginResponseListener);
          loginResponseListener.showSuccessLogin(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  loginByDoctor(String phone, String password,
      LoginResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "doctor_phone": phone,
      "doctor_password": password
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.DOCTOR_LOGIN;
    print(url);
    try {
      final response = await http.post(Uri.parse(url), body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<LoginData> baseResponse =
            BaseResponse<LoginData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          NotificationsNetwork notificationsNetwork = NotificationsNetwork();
          await notificationsNetwork.subscribeNotification(
              baseResponse.data ?? LoginData(), loginResponseListener);
          loginResponseListener.showSuccessLogin(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  getInterests(InterestsResponseListener interestsResponseListener) async {
    interestsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);
    String url = ApiUrls.MAIN_URL + ApiUrls.GET_INTERESTS;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      interestsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<InterestsData> baseResponse =
            BaseResponse<InterestsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          interestsResponseListener.setInterests(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          interestsResponseListener.showServerError(baseResponse.message);
        } else {
          interestsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          interestsResponseListener.showServerError(baseResponse.message);
        } else {
          interestsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
//        BaseResponse baseResponse =
//            BaseResponse.fromJson(json.decode(response.body));
//        if (baseResponse.message != null) {
//          interestsResponseListener.showServerError(baseResponse.message);
//        } else {
//          interestsResponseListener.showGeneralError();
//        }
        interestsResponseListener.showAuthError();
      } else {
        interestsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        interestsResponseListener.hideLoading();
        interestsResponseListener.showGeneralError();
      } else {
        print('network error');
        interestsResponseListener.hideLoading();
        interestsResponseListener.showNetworkError();
      }
    }
  }

  updateInterests(String teams, String events, String news, String trips,
      InterestsResponseListener interestsResponseListener) async {
    interestsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
//    token =
//        'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1NjcwMDI0MDMsImV4cCI6MTU2NzA4ODgwMywiaWQiOjczLCJ1c2VyX2xvZ2luIjoiQWJkZWxtYWdpZCBNYXR0YXIgU2hhYmFuIn0.JSlRGww7E_ndJVGAjJbKztGjCNAZbXh_icX0t8vuMwM';

    Map<String, String> headers = {
      'Authorization': token,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    print(headers);

    Map<String, dynamic> parameters = {
      "teams": teams,
      "events": events,
      "news": news,
      "trips": trips,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_INTERESTS;
    print(url);
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      interestsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        interestsResponseListener.showUpdateSuccess();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          interestsResponseListener.showServerError(baseResponse.message);
        } else {
          interestsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          interestsResponseListener.showServerError(baseResponse.message);
        } else {
          interestsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
//        BaseResponse baseResponse =
//            BaseResponse.fromJson(json.decode(response.body));
//        if (baseResponse.message != null) {
//          interestsResponseListener.showServerError(baseResponse.message);
//        } else {
//          interestsResponseListener.showGeneralError();
//        }
        interestsResponseListener.showAuthError();
      } else {
        interestsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        interestsResponseListener.hideLoading();
        interestsResponseListener.showGeneralError();
      } else {
        print('network error');
        interestsResponseListener.hideLoading();
        interestsResponseListener.showNetworkError();
      }
    }
  }

  Future<void> refreshToken(
      LoginResponseListener refreshTokenResponseListener) async {
    String token = "";
    if (LocalSettings.refreshToken != "") {
      token = LocalSettings.refreshToken ?? "";
    }

    Map<String, String> parameters = {
      'refreshToken': token,
    };
    print(token);
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.REFRESH_TOKEN;
    print(url);
    try {
      final response = await http.post(Uri.parse(url), body: parameters);
      refreshTokenResponseListener.hideLoading();
      print('response' + response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        BaseResponse<LoginData> baseResponse =
            BaseResponse<LoginData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          refreshTokenResponseListener.showSuccessLogin(baseResponse.data);
        } else {
          refreshTokenResponseListener.showGeneralError();
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          refreshTokenResponseListener.showServerError(baseResponse.message);
        } else {
          refreshTokenResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED ||
          response.statusCode == INVALIDTOKEN ||
          response.statusCode == INVALIDREFRESHTOKEN) {
        refreshTokenResponseListener.showAuthError();
      } else {
        refreshTokenResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        refreshTokenResponseListener.hideLoading();
        refreshTokenResponseListener.showGeneralError();
      } else {
        print('network error');
        refreshTokenResponseListener.hideLoading();
        refreshTokenResponseListener.showNetworkError();
      }
    }
  }

  getProfile(LoginResponseListener profileResponseListener) async {
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);
    profileResponseListener.showLoading();
    String url = ApiUrls.MAIN_URL + ApiUrls.GET_PROFILE;
    print(url);

    try {
      final response = await http.post(Uri.parse(url), headers: headers);
      profileResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<LoginData> baseResponse =
            BaseResponse<LoginData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          profileResponseListener.showSuccessLogin(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          profileResponseListener.showServerError(baseResponse.message);
        } else {
          profileResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          profileResponseListener.showServerError(baseResponse.message);
        } else {
          profileResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        profileResponseListener.showAuthError();
      } else {
        profileResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        profileResponseListener.hideLoading();
        profileResponseListener.showGeneralError();
      } else {
        print('network error');
        profileResponseListener.hideLoading();
        profileResponseListener.showNetworkError();
      }
    }
  }

  checkNationalId(String user_membernationalid,
      BasicResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membernationalid": user_membernationalid
    };
    print(parameters.toString());
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.CHECK_NATIONAL_ID),
          body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccess(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showLoginError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  updatePhone(String user_membernationalid, String phone,
      BasicResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membernationalid": user_membernationalid,
      "user_phone": phone
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_PHONE;
    print(url);
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.UPDATE_PHONE),
          body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccess(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showLoginError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  registerPayment(String userMembership, String email, String phone,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
      "user_email": email,
      "user_phone": phone
    };
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.Payment_first_step;
    print(url);
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.Payment_first_step),
          body: parameters,
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccessID(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          // loginResponseListener.showAuthError();
          if (json.decode(response.body)["data"] != null &&
              json.decode(response.body)["data"]["update_url"] != null) {
            loginResponseListener.showPhoneError(baseResponse.message);
          } else {
            loginResponseListener.showErrorMsg(baseResponse.message);
          }
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showPhoneError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        // = 400;

        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          if (json.decode(response.body)["data"] != null &&
              json.decode(response.body)["data"]["update_url"] != null) {
            loginResponseListener.showEmailError(
                errorMsg: baseResponse.message);
          } else {
            loginResponseListener.showErrorMsg(baseResponse.message);
          }
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  checkMemberidInLogin(String userMembership,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_first_step;
    print(url);
    // String token = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDQ0ODA2NDAsImV4cCI6MTYwNDU2NzA0MCwiaWQiOiIwMTI3NDU0ODIxMiJ9.UHtOSVlI0tlDF11uovTDwTLNtuzoh24jl6KvsbnhIJM";
//    if (LocalSettings.token != "") {
//      token = LocalSettings.token??"";
//    }
//    Map<String, String> headers = {
//      'Authorization': token,
//    };
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.UPDATE_first_step),
          body: parameters);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccessID(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showPhoneError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        // = 400;InvalidValues

        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showEmailError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  verifyLoginPayment(String code, String membershipid, bool loader,
      PaymentResponseListener loginResponseListener) async {
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    if (loader) {
      loginResponseListener.showLoading();
    }

    Map<String, dynamic> parameters = {
      "verification_code": code,
      "user_membership": membershipid
    };
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.Payment_Sec_step;
    print(url);
    print("token" + token);

    try {
      final response =
          await http.post(Uri.parse(url), body: parameters, headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<PaymentData> baseResponse =
            BaseResponse<PaymentData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          loginResponseListener.showSuccess(baseResponse.data,
              serverMessage: baseResponse.message);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showInvalidCode(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  checkMemberid(String userMembership,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_membership": userMembership,
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_first_step;
    print(url);
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.UPDATE_first_step),
          body: parameters,
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccessID(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showAuthError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showPhoneError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        // = 400;

        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showEmailError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  checkStepTwo(String userNationalId, String userBirthday, userMembership,
      UpdateMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters;
    if (userNationalId == "") {
      parameters = {
        "user_birthday": userBirthday,
        "user_membership": userMembership,
      };
    } else if (userBirthday == "") {
      parameters = {
        "user_national_id": userNationalId,
        "user_membership": userMembership,
      };
    } else {
      parameters = {
        "user_national_id": userNationalId,
        "user_birthday": userBirthday,
        "user_membership": userMembership,
      };
    }

    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_Sec_step;
    print(url);
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.UPDATE_Sec_step),
          body: parameters,
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<UserUpdateData> baseResponse =
            BaseResponse<UserUpdateData>.fromJson(json.decode(response.body));
        loginResponseListener.showSecondStepSuccess(baseResponse.data?.user,
            baseResponse.data?.updated, baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          // loginResponseListener.showAuthError();
          loginResponseListener.showServerError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showPhoneError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        // = 400;

        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showError(baseResponse.message);
//          loginResponseListener.showGeneralError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }

  checkStepThree(
      String national_id,
      String email,
      String phone,
      String userMembership,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "user_national_id": national_id,
      "user_email": email,
      "user_phone": phone,
      "user_membership": userMembership,
    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_Third_step;
    print(url);
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    try {
      final response = await http.post(
          Uri.parse(ApiUrls.MAIN_URL + ApiUrls.UPDATE_Third_step),
          body: parameters,
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        loginResponseListener.showSuccessID(baseResponse.message);
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showAuthError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showPhoneError(baseResponse.message);
        } else {
          loginResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        // = 400;

        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          loginResponseListener.showEmailError();
        } else {
          loginResponseListener.showGeneralError();
        }
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        loginResponseListener.hideLoading();
        loginResponseListener.showGeneralError();
      } else {
        print('network error');
        loginResponseListener.hideLoading();
        loginResponseListener.showNetworkError();
      }
    }
  }
}
