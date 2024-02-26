import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/data/model/advertisements_list_data.dart';
import 'package:sporting_club/data/model/contacting_info_data.dart';
import 'package:sporting_club/data/model/emergency_data.dart';
import 'package:sporting_club/data/model/images_list_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/ContactingInfoResponseListener.dart';
import 'package:sporting_club/network/listeners/ImagesResponseListener.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/MoreResponseListener.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import '../api_urls.dart';
import 'dart:convert';

class InfoNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  LocalSettings _localSettings = LocalSettings();

  getContactingInfo(
      ContactingInfoResponseListener contactingInfoListener) async {
    contactingInfoListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL + ApiUrls.CONTACTING_INFO;
    print(url);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      contactingInfoListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ContactingInfoData> baseResponse =
            BaseResponse<ContactingInfoData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          contactingInfoListener.setData(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          contactingInfoListener.showServerError(baseResponse.message);
        } else {
          contactingInfoListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          contactingInfoListener.showServerError(baseResponse.message);
        } else {
          contactingInfoListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        contactingInfoListener.showAuthError();
      } else {
        contactingInfoListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        contactingInfoListener.hideLoading();
        contactingInfoListener.showGeneralError();
      } else {
        print('network error');
        contactingInfoListener.hideLoading();
        contactingInfoListener.showImageNetworkError();
      }
    }
  }

  contactUs(String name, String email, String address, String content,
      BasicResponseListener responseListener) async {
    responseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    Map<String, dynamic> parameters = {
      'name': name,
      "email": email,
      'address': address,
      'body': content,
    };

    String url = ApiUrls.MAIN_URL + ApiUrls.CONTACT_US;
    print(url);

    try {
      final response = await http.post(Uri.parse(url), headers: headers);
      responseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        responseListener.showSuccess("");
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          responseListener.showServerError(baseResponse.message);
        } else {
          responseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          responseListener.showServerError(baseResponse.message);
        } else {
          responseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        responseListener.showAuthError();
      } else {
        responseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        responseListener.hideLoading();
        responseListener.showGeneralError();
      } else {
        print('network error');
        responseListener.hideLoading();
        responseListener.showNetworkError();
      }
    }
  }

  getEmergencyNumbers(MoreResponseListener moreListener) async {
    moreListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL + ApiUrls.EMERGENCY;
    print(url);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      moreListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<EmergencyData> baseResponse =
            BaseResponse<EmergencyData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          moreListener.setData(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          moreListener.showServerError(baseResponse.message);
        } else {
          moreListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          moreListener.showServerError(baseResponse.message);
        } else {
          moreListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        moreListener.showAuthError();
      } else {
        moreListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        moreListener.hideLoading();
        moreListener.showGeneralError();
      } else {
        print('network error');
        moreListener.hideLoading();
        moreListener.showNetworkError();
      }
    }
  }

  getAdsList(LoginData? loginData, LoginResponseListener? loginResponseListener,
      HomeState? home) async {
    if (loginResponseListener != null) {
      loginResponseListener.showLoading();
    }
    String token = "";
    if (loginData != null) {
      if (loginData.token != null) {
        token = "Bearer " + (loginData.token??"");
      }
    } else if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL + ApiUrls.ADVERTISEMENTS;
    print(url);

    try {
      final response = await http.post(  Uri.parse(url), headers: headers);
      if (loginResponseListener != null) {
        loginResponseListener.hideLoading();
      }
      print('response' + response.body);
      LocalSettings.adsNetworkError = false;
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<AdvertisementsListData> baseResponse =
            BaseResponse<AdvertisementsListData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          print(baseResponse.data?.advertisement?.length);
          LocalSettings.advertisements = baseResponse.data;

          if (home != null) {
            home.getAds();
          }
          if (loginResponseListener != null) {
            loginResponseListener.showSuccessLogin(loginData);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        if (loginResponseListener != null) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            loginResponseListener.showServerError(baseResponse.message);
          } else {
            loginResponseListener.showGeneralError();
          }
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        if (loginResponseListener != null) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            loginResponseListener.showServerError(baseResponse.message);
          } else {
            loginResponseListener.showGeneralError();
          }
        }
      } else if (response.statusCode == INVALIDTOKEN) {
      } else {}
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        if (loginResponseListener != null) {
          loginResponseListener.hideLoading();
          loginResponseListener.showGeneralError();
        }
      } else {
        print('network error');
        LocalSettings.adsNetworkError = true;
        if (loginResponseListener != null) {
          loginResponseListener.hideLoading();
          loginResponseListener.showNetworkError();
        }
      }
    }
  }




  getImageList(
      ImagesResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    print(headers);
    String url = ApiUrls.MAIN_URL + ApiUrls.HOME_Images;
    print(url);
    try {
      final response = await http.post(Uri.parse(ApiUrls.MAIN_URL + ApiUrls.HOME_Images),
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ImagesListData> baseResponse =
        BaseResponse<ImagesListData>.fromJson(
            json.decode(response.body));
        if (baseResponse.data != null) {
          print("base");


          if (loginResponseListener != null) {
            loginResponseListener.showSuccess(baseResponse.data);
          }
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
}
