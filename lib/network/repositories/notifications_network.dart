import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/notifications_data.dart';
import 'package:sporting_club/data/model/subscription_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/MoreResponseListener.dart';
import 'package:sporting_club/network/listeners/NotificationsResponseListener.dart';
import 'package:sporting_club/network/listeners/NotificationsSettingsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';

import '../api_urls.dart';
import 'info_network.dart';

class NotificationsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  LocalSettings _localSettings = LocalSettings();

  subscribeNotification(
      LoginData loginData, LoginResponseListener loginResponseListener) async {
    loginResponseListener.showLoading();

    String token = "";
    if (loginData.token != null) {
      token = "Bearer " + (loginData.token ?? "");
    }
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

//    String playerId;
//    if (LocalSettings.playerId == null) {
//      playerId = await getPlayerId();
//    } else {
//      if (LocalSettings.playerId.isEmpty) {
//        playerId = await getPlayerId();
//      } else {
//        playerId = LocalSettings.playerId;
//      }
//    }

    String? notificationToken = "";

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    if (LocalSettings.playerId != null && LocalSettings.playerId != "") {
      //print('send playerId'+LocalSettings.playerId);
      notificationToken = LocalSettings.playerId;
    } else if (LocalSettings.firebaseToken != null &&
        LocalSettings.firebaseToken != "") {
      print('send firebaseToken');
      notificationToken = LocalSettings.firebaseToken;
    } else {
      if (Platform.isAndroid) {
        notificationToken = await firebaseMessaging.getToken();
        print("notificationToken$notificationToken");
      } else {
        await getIOSFirebaseToken();
        notificationToken = LocalSettings.firebaseToken;
      }
    }
    if (notificationToken == "") {
      print('notificationToken = null');
      loginResponseListener.hideLoading();
      loginResponseListener.showGeneralError();
    } else {
      Map<String, dynamic> parameters = {
        "device_token": notificationToken,
        "device_type": Platform.isIOS ? 0 : 1
      };
      print(parameters.toString());

      String url = ApiUrls.MAIN_URL + ApiUrls.SUBSCRIBE_NOTIFICATIONS;
      print(url);
      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: json.encode(parameters));
        loginResponseListener.hideLoading();
        print('response' + response.body);
        print('status code: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          print('success');
          InfoNetwork _infoNetwork = InfoNetwork();
          _infoNetwork.getAdsList(loginData, loginResponseListener, null);
//          loginResponseListener.showSuccess(loginData);
          BaseResponse<SubscriptionData> baseResponse =
              BaseResponse<SubscriptionData>.fromJson(
                  json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.playerId != null) {
              _localSettings.setPlayerId(baseResponse.data?.playerId);
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

  unsubscribeNotification(MoreResponseListener moreResponseListener) async {
    moreResponseListener.showLoading();

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

    String? playerId = await _localSettings.getPlayerId();
// print("playerid${_localSettings}_localSettings");
    print("player_id${LocalSettings.playerId}");

    if (LocalSettings.playerId == null) {
      moreResponseListener.showLogoutSuccess();
    } else {
      Map<String, dynamic> parameters = {"player_id": playerId};
      print(parameters.toString());

      String url = ApiUrls.MAIN_URL + ApiUrls.UNSUBSCRIBE_NOTIFICATIONS;
      print(url);
      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: json.encode(parameters));
        moreResponseListener.hideLoading();
        print('response' + response.body);
        print('status code: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          print('success');
          moreResponseListener.showLogoutSuccess();
        } else if (response.statusCode == InvalidValues) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            moreResponseListener.showServerError(baseResponse.message);
          } else {
            moreResponseListener.showLogoutSuccess();
          }
        } else if (response.statusCode == UNAUTHORIZED) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            moreResponseListener.showServerError(baseResponse.message);
          } else {
            moreResponseListener.showLogoutSuccess();
          }
        } else {
          moreResponseListener.showLogoutSuccess();
        }
      } catch (error) {
//      print("error: " + error);
        var connectivityResult = await (Connectivity().checkConnectivity());
        if ((connectivityResult == ConnectivityResult.mobile) ||
            (connectivityResult == ConnectivityResult.wifi)) {
          print('ConnectivityResult mobile or wifi');
          moreResponseListener.hideLoading();
          moreResponseListener.showGeneralError();
        } else {
          print('network error');
          moreResponseListener.hideLoading();
          moreResponseListener.showNetworkError();
        }
      }
    }
  }

  // Future<String> getPlayerId() async {
  //   var status = await OneSignal.shared.getPermissionSubscriptionState();
  //   String oneSignalPlayerId = status.subscriptionStatus.userId;
  //   if (oneSignalPlayerId != null) {
  //     print(oneSignalPlayerId);
  //     LocalSettings localSettings = LocalSettings();
  //     localSettings.setPlayerId(oneSignalPlayerId);
  //   }
  //   return oneSignalPlayerId;
  // }

  getNotifications(int page, bool isNeedLoading,
      NotificationsResponseListener notificationsListener) async {
    if (isNeedLoading) {
      notificationsListener.showLoading();
    }
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

    Map<String, dynamic> parameters = {
      'page': page,
      'limit': 20,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.NOTIFICATIONS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      notificationsListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse<NotificationsData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          notificationsListener.setNotifications(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        notificationsListener.showAuthError();
      } else {
        notificationsListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        notificationsListener.hideLoading();
        notificationsListener.showGeneralError();
      } else {
        print('network error');
        notificationsListener.hideLoading();
        if (page == 1) {
          notificationsListener.showImageNetworkError();
        } else {
          notificationsListener.showNetworkError();
        }
      }
    }
  }

  setNotificationsSeen(notification_id,
      NotificationsResponseListener notificationsListener) async {
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, dynamic> parameters = {
      "notification_id": notification_id,
    };
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL + ApiUrls.NOTIFICATIONS_READ;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        notificationsListener.showAuthError();
      } else {
        notificationsListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        notificationsListener.hideLoading();
        notificationsListener.showGeneralError();
      } else {
        print('network error');
        notificationsListener.hideLoading();
        notificationsListener.showNetworkError();
      }
    }
  }

  changeNotificationsStatus(bool status, bool sound,
      NotificationsSettingsResponseListener notificationsListener) async {
    notificationsListener.showLoading();
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

    Map<String, dynamic> parameters = {
      "notification_status": status ? "on" : "off",
      "notification_sound": sound ? "on" : "off"
    };
    print(parameters.toString());

    String url = ApiUrls.MAIN_URL + ApiUrls.NOTIFICATIONS_STATUS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      notificationsListener.hideLoading();
      if (response.statusCode == 200) {
        print('success');
        notificationsListener.showChangeStatusSuccess();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        notificationsListener.showAuthError();
      } else {
        notificationsListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        notificationsListener.hideLoading();
        notificationsListener.showGeneralError();
      } else {
        print('network error');
        notificationsListener.hideLoading();
        notificationsListener.showNetworkError();
      }
    }
  }

  Future<void> getIOSFirebaseToken() async {
    const platform = const MethodChannel('getIOSFirebaseToken');

    String firebaseToken;
    try {
      firebaseToken = await platform.invokeMethod('getIOSFirebaseToken');
      print(firebaseToken + '    ios native code');
      LocalSettings.firebaseToken = firebaseToken;
    } on PlatformException catch (e) {
      print("Failed to get data from native : '${e.message}'.");
    }
  }

  getNotificationInterests(
      NotificationsSettingsResponseListener interestsResponseListener) async {
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
    String url = ApiUrls.MAIN_URL + ApiUrls.GET_INTERESTS_NOTIFICATION;
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
        interestsResponseListener.showImageNetworkError();
      }
    }
  }

  updateInterestsNotification(
      String teams,
      String events,
      String news,
      String trips,
      NotificationsSettingsResponseListener interestsResponseListener) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.UPDATE_NOTIFICATIONS_STATUS;
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

  deleteSpecficNotification(notification_id,
      NotificationsResponseListener notificationsListener) async {
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token ?? "";
    }
    Map<String, dynamic> parameters = {
      "notification_id": notification_id,
    };
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL + ApiUrls.NOTIFICATIONS_DELETE;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        notificationsListener.showSucessDelete();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        notificationsListener.showAuthError();
      } else {
        notificationsListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        notificationsListener.hideLoading();
        notificationsListener.showGeneralError();
      } else {
        print('network error');
        notificationsListener.hideLoading();
        notificationsListener.showNetworkError();
      }
    }
  }

  deleteAllNotification(
      NotificationsResponseListener notificationsListener) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.NOTIFICATIONS_DELETE_All;
    print(url);

    try {
      final response = await http.post(Uri.parse(url), headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        notificationsListener.showSucessDeleteAll();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          notificationsListener.showServerError(baseResponse.message);
        } else {
          notificationsListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        notificationsListener.showAuthError();
      } else {
        notificationsListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        notificationsListener.hideLoading();
        notificationsListener.showGeneralError();
      } else {
        print('network error');
        notificationsListener.hideLoading();
        notificationsListener.showNetworkError();
      }
    }
  }
}
