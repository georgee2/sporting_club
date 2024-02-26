import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_list_response.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_price_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_traffic_response.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride_result.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

class SwvlRidesNetwork {
  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  SwvlRidesNetwork() {
    print("init ShuttleBusNetwork");
  }


  Future<BaseResponse<Rides>> getSwvlRideDetails(
      {required String rideId}) async {
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

    String url = ApiUrls.MAIN_URL + ApiUrls.SWVL_RIDE_DETAILS+"?id=${rideId}";
    print(url);

    try {
      final response = await http.get(Uri.parse(url),
          headers: headers,
         );
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        BaseResponse<Rides> baseResponse =
            BaseResponse<Rides>.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == InvalidValues) {
        BaseResponse<Rides> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse<Rides> baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        return baseResponse;
      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse<Rides> baseResponse =
            BaseResponse(statusCode: INVALIDTOKEN);
        return baseResponse;
      } else {
        print('success5');
        BaseResponse<Rides> baseResponse =
            BaseResponse(statusCode: 500);
        return baseResponse;
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      BaseResponse<Rides> baseResponse;
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


  Future<BaseResponse<SwvlRideResult>> getSwvlRideList(int? page, status) async {
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
            'limit': 10,
      "status":status
          }
        : {};
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SWVL_RIDE_LIST+"?page=$page&limit=10&status=$status";
    print(url);

    try {
      final response = await http.get(Uri.parse(url),
          headers: headers, );
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      BaseResponse<SwvlRideResult> baseResponse;
      if (response.statusCode == 200) {
        print('success');
        baseResponse = BaseResponse<SwvlRideResult>.fromJson(
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
      BaseResponse<SwvlRideResult> baseResponse;
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
