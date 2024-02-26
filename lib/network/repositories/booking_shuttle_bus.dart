import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_list_response.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_price_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_traffic_response.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

class ShuttleBusNetwork {
  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  ShuttleBusNetwork() {
    print("init ShuttleBusNetwork");
  }

  Future<BaseResponse<ShuttleData>> getShuttlePackages() async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.SHUTTLE_BUS_DISPLAY_FORM;
    print(url);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttleData> baseResponse =
            BaseResponse<ShuttleData>.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttleData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttleData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttleData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttleData> baseResponse = BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleData> baseResponse;
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

  Future<BaseResponse<ShuttleBookingData>> checShuttleBooking(
      {required String subType}) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.CHECK_SHUTTLE_BOOKING;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({"sub_type": subType}), headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttleBookingData> baseResponse =
            BaseResponse<ShuttleBookingData>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttleBookingData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttleBookingData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttleBookingData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttleBookingData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleBookingData> baseResponse;
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

  Future<BaseResponse<ShuttlePriceData>> calculatePriceForMembers({
    required String subType,
    required String totalMembers,
    required startDate,
    required endDate,
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

    String url = ApiUrls.MAIN_URL + ApiUrls.CALCULATE_PRICE_FIRST_SCREEN;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "sub_type": subType,
            "total_members": totalMembers,
            "start_date": startDate,
            "end_date": endDate,
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttlePriceData> baseResponse =
            BaseResponse<ShuttlePriceData>.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttlePriceData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttlePriceData> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttlePriceData> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttlePriceData> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttlePriceData> baseResponse;
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

  Future<BaseResponse<ShuttleFees>> calculatePrice({
    required String subType,
    required String totalMembers,
    required startDate,
    required endDate,
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

    String url = ApiUrls.MAIN_URL + ApiUrls.CALCULATE_PRICE;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "sub_type": subType,
            "total_members": totalMembers,
            "start_date": startDate,
            "end_date": endDate,
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttleFees> baseResponse =
            BaseResponse<ShuttleFees>.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttleFees> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttleFees> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttleFees> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttleFees> baseResponse = BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleFees> baseResponse;
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

  Future<BaseResponse<OnlineBookingPayment>> createPendingBooking({
    required String subType,
    required String memberIds,
    required String startDate,
    required String endDate,
    required String totalPrice,
    required String totalDiscount,
    required String totalBeforeFees,
    required String favouriteLines,
    required String comment,
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

    String url = ApiUrls.MAIN_URL + ApiUrls.CREATE_PENDING_BOOKING;
    print(url);
    print({
      "sub_type": subType,
      "member_ids": memberIds,
      "start_date": startDate,
      "end_date": endDate,
      "total_price": totalPrice,
      "total_discount": totalDiscount,
      "total_before_discount": totalBeforeFees,
      "favourite_lines": favouriteLines,
      "comment": comment,
    });
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "sub_type": subType,
            "member_ids": memberIds,
            "start_date": startDate,
            "end_date": endDate,
            "total_price": totalPrice,
            "total_discount": totalDiscount,
            "total_before_discount": totalBeforeFees,
            "favourite_lines": favouriteLines,
            "comment": comment,
          }),
          headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<OnlineBookingPayment> baseResponse =
            BaseResponse<OnlineBookingPayment>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<OnlineBookingPayment> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<OnlineBookingPayment> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        Map<String, dynamic> map = json.decode(response.body);
        BaseResponse<OnlineBookingPayment> baseResponse;
        if (map["data"] is String) {
          baseResponse = BaseResponse(statusCode: INVALIDTOKEN);
        } else {
          baseResponse = BaseResponse.fromJson(json.decode(response.body));
        }
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<OnlineBookingPayment> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<OnlineBookingPayment> baseResponse;
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

  Future<BaseResponse<ShuttleDetails>> getShuttleDetails(
      {required String shuttleId}) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.SHUTTLE_BOOKING_DETAILS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers,
          body: json.encode({
            "booking_id": shuttleId,
          }));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttleDetails> baseResponse =
            BaseResponse<ShuttleDetails>.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttleDetails> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttleDetails> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttleDetails> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttleDetails> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleDetails> baseResponse;
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

  Future<BaseResponse<ShuttleListResponse>> getShuttleList(int page) async {
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
      'limit': 7,
    };
    String url = ApiUrls.MAIN_URL + ApiUrls.SHUTTLE_BOOKING_LIST;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<ShuttleListResponse> baseResponse =
            BaseResponse<ShuttleListResponse>.fromJson(
                json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<ShuttleListResponse> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<ShuttleListResponse> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<ShuttleListResponse> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<ShuttleListResponse> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleListResponse> baseResponse;
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

  Future<BaseResponse<ShuttleTrafficResponse>> getTrafficList(int? page) async {
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

    Map<String, dynamic> parameters = page != null
        ? {
            'page': page,
            'limit': 12,
          }
        : {};
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SHUTTLE_TRAFFIC_LIST;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      BaseResponse<ShuttleTrafficResponse> baseResponse;
      if (response.statusCode == 200) {
        print('success');
        baseResponse = BaseResponse<ShuttleTrafficResponse>.fromJson(
            json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        baseResponse = BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        baseResponse = BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        baseResponse = BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        baseResponse = BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<ShuttleTrafficResponse> baseResponse;
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
