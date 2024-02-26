import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/fees.dart';
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/online_membership_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';
import 'package:sporting_club/data/model/user_update_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/InterestsResponseListener.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/MoreResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentMembershipResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentTypeResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/listeners/UpdateMembershipListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'notifications_network.dart';

class PaymentNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;


  calculateFees(String total_amount,
      RegisterMembershipListener loginResponseListener) async {
    loginResponseListener.showLoading();
    Map<String, dynamic> parameters = {
      "total_amount": total_amount,

    };
    print(parameters.toString());
    String url = ApiUrls.MAIN_URL + ApiUrls.Caluculate_fees;
    print(url);
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    try {
      final response = await http.post(Uri.parse(url),
          body: parameters,
          headers: headers);
      loginResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());

      if (response.statusCode == 200) {
        print('success');
        BaseResponse<Fees> baseResponse =
        BaseResponse<Fees>.fromJson(json.decode(response.body));

        if (baseResponse.data != null) {
          double value = baseResponse.data?.total_amout_with_fees;
          print('success3');

          loginResponseListener.showSuccessID(
            '$value');
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
        loginResponseListener.showAuthError();
      } else {
        loginResponseListener.showGeneralError();
      }
    } catch (error) {
     // print("error: " + error);
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

  requestPayment(
     String  payment_total_cost,
       String remaining ,
      String cars,
      String has_service,
  String id,

  PaymentMembershipResponseListener paymentTypeListener) async {
    paymentTypeListener.showLoading();
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

    String url = ApiUrls.MAIN_URL +
        ApiUrls.Request_PAy;
    print(url);
    Map<String, dynamic> parameters = {
      "payment_total_cost": payment_total_cost,
      "remaining": remaining,
      "cars": cars,
      "has_service": has_service,
      "user_membership":id,



    };

    print(parameters);

    try {
      final response =
      await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      paymentTypeListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');

        BaseResponse<OnlineMembershipPayment> baseResponse =
        BaseResponse<OnlineMembershipPayment>.fromJson(
              json.decode(response.body));
          if (baseResponse.data != null) {
            paymentTypeListener.showSuccessOnline(baseResponse.data);
          }
        }
       else if (response.statusCode == InvalidValues) {
    BaseResponse baseResponse =
    BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      }
       else if (response.statusCode == 422) {
    BaseResponse baseResponse =
    BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
    BaseResponse baseResponse =
    BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        paymentTypeListener.showAuthError();
      } else {
        paymentTypeListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showGeneralError();
      } else {
        print('network error');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showNetworkError();
      }
    }
  }

}
