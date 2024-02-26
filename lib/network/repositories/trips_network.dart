import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/event_details_data.dart';
import 'package:sporting_club/data/model/events_data.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'package:sporting_club/data/model/news_details_data.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/model/trips/trips_interests_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/TripDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/TripsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class TripsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 401;

  getTrips(int category, int page, bool isNeedLoading,String? filterDate,
      TripsResponseListener tripsResponseListener) async {
    if (isNeedLoading) {
      tripsResponseListener.showLoading();
    }
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

    String url = ApiUrls.BOOKING_MAIN_URL +
        ApiUrls.TRIPS +
        "?category=" +
        category.toString() +
        (filterDate!=null? "&monthFilter="+filterDate:"")+
        "&page=" +
        page.toString() +
        "&limit=10";
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      tripsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TripsData> baseResponse =
            BaseResponse<TripsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          tripsResponseListener.setTrips(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripsResponseListener.showServerError(baseResponse.message);
        } else {
          tripsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripsResponseListener.showServerError(baseResponse.message);
        } else {
          tripsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        tripsResponseListener.showAuthError();
      } else {
        tripsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: $error" );
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        tripsResponseListener.hideLoading();
        tripsResponseListener.showGeneralError();
      } else {
        print('network error');
        tripsResponseListener.hideLoading();
        if (page == 1) {
          tripsResponseListener.showImageNetworkError();
        } else {
          tripsResponseListener.showNetworkError();
        }
      }
    }
  }

  getTripsInterests(TripsResponseListener tripsResponseListener) async {
    tripsResponseListener.showLoading();
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

    String url = ApiUrls.BOOKING_MAIN_URL + ApiUrls.TRIPS_INTERESTS;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      tripsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TripsInterestsData> baseResponse =
            BaseResponse<TripsInterestsData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          tripsResponseListener.setInterests(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripsResponseListener.showServerError(baseResponse.message);
        } else {
          tripsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripsResponseListener.showServerError(baseResponse.message);
        } else {
          tripsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        tripsResponseListener.showAuthError();
      } else {
        tripsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        tripsResponseListener.hideLoading();
        tripsResponseListener.showGeneralError();
      } else {
        print('network error');
        tripsResponseListener.hideLoading();
        tripsResponseListener.showImageNetworkError();
      }
    }
  }

  getTripDetails(
      int id, TripDetailsResponseListener tripResponseListener) async {
    tripResponseListener.showLoading();
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

    String url = ApiUrls.BOOKING_MAIN_URL + ApiUrls.TRIPS + "/" + id.toString();
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      tripResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TripDetailsData> baseResponse =
            BaseResponse<TripDetailsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          print('success2');

          tripResponseListener.setTrip(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripResponseListener.showServerError(baseResponse.message);
        } else {
          print('success3');

          tripResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          tripResponseListener.showServerError(baseResponse.message);
        } else {
          print('success4');

          tripResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        tripResponseListener.showAuthError();
      } else {
        print('success5');

        tripResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: $error" );
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        tripResponseListener.hideLoading();
        tripResponseListener.showGeneralError();
      } else {
        print('network error');
        tripResponseListener.hideLoading();
        tripResponseListener.showImageNetworkError();
      }
    }
  }
}
