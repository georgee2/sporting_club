import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/emergency/emergency_category.dart';
import 'package:sporting_club/data/model/emergency/emergency_category_data.dart';
import 'package:sporting_club/data/model/notification.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_list_response.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_price_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_traffic_response.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../../data/model/notifications_data.dart';
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

class EmergencyNetwork {
  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 400;
  static int INVALIDTOKEN = 401;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  EmergencyNetwork() {
    print("init ShuttleBusNetwork");
  }

  Future<BaseResponse<EmergencyCategoryData>> getEmergencyCategoryList() async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.Doctor_Categories;
    print(url);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse<EmergencyCategoryData>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        // BaseResponse<EmergencyCategoryData> baseResponse =
        //     BaseResponse.fromJson(json.decode(response.body));
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: UNAUTHORIZED);
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<EmergencyCategoryData> baseResponse;
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        baseResponse = BaseResponse(statusCode: 500);
      } else {
        print('network error');
        baseResponse = BaseResponse(statusCode: NO_NETWORK);
      }
      return baseResponse;
    }
  }

  Future<BaseResponse<NotificationsData>> getEmergencyCategoryDetails(
      notification_id) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.Doctor_Notification;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "notification_id": notification_id,
          }),
          headers: headers);
      debugPrint('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse<NotificationsData>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<NotificationsData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<NotificationsData> baseResponse;
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        baseResponse = BaseResponse(statusCode: 500);
      } else {
        print('network error');
        baseResponse = BaseResponse(statusCode: NO_NETWORK);
      }
      return baseResponse;
    }
  }

  Future<BaseResponse<EmergencyCategoryData>> sendSOS({
    required String category,
    required String location,
    required String sosName,
    required String sosPhone,
  }) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.SEND_SOS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "category": category,
            "location": location,
            "sos_name": sosName,
            "sos_phone": sosPhone
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse<EmergencyCategoryData>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<EmergencyCategoryData> baseResponse;
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        baseResponse = BaseResponse(statusCode: 500);
      } else {
        print('network error');
        baseResponse = BaseResponse(statusCode: NO_NETWORK);
      }
      return baseResponse;
    }
  }

  Future<BaseResponse<EmergencyCategoryData>> acceptSOS({
    required String uniqueId,
    required String sosId,
  }) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.Doctor_ACCEPT_SOS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "unique": uniqueId,
            "sos_id": sosId,
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse<EmergencyCategoryData>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<EmergencyCategoryData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<EmergencyCategoryData> baseResponse;
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        baseResponse = BaseResponse(statusCode: 500);
      } else {
        print('network error');
        baseResponse = BaseResponse(statusCode: NO_NETWORK);
      }
      return baseResponse;
    }
  }

  Future<BaseResponse<EmergencyCategoryData>> rejectSOS({
    required String sosId,
  }) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.Doctor_REJECT_SOS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "sos_id": sosId,
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<EmergencyCategoryData> baseResponse =
        BaseResponse<EmergencyCategoryData>.fromJson(
            json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<EmergencyCategoryData> baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<EmergencyCategoryData> baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<EmergencyCategoryData> baseResponse =
        BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<EmergencyCategoryData> baseResponse =
        BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<EmergencyCategoryData> baseResponse;
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        baseResponse = BaseResponse(statusCode: 500);
      } else {
        print('network error');
        baseResponse = BaseResponse(statusCode: NO_NETWORK);
      }
      return baseResponse;
    }
  }
}
