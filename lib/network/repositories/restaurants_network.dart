import 'package:sporting_club/data/model/restaurants_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/RestaurantsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class RestaurantsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getRestaurants(RestaurantResponseListener restaurantResponseListener) async {
    restaurantResponseListener.showLoading();
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

    String url = ApiUrls.MAIN_URL + ApiUrls.RESTAURANTS;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      restaurantResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RestaurantsData> baseResponse =
            BaseResponse<RestaurantsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          restaurantResponseListener.setRestaurants(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          restaurantResponseListener.showServerError(baseResponse.message);
        } else {
          restaurantResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          restaurantResponseListener.showServerError(baseResponse.message);
        } else {
          restaurantResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        restaurantResponseListener.showAuthError();
      } else {
        restaurantResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        restaurantResponseListener.hideLoading();
        restaurantResponseListener.showGeneralError();
      } else {
        print('network error');
        restaurantResponseListener.hideLoading();
        restaurantResponseListener.showImageNetworkError();
      }
    }
  }

  getRestaurantDetails(
      String id, RestaurantResponseListener restaurantResponseListener) async {
    restaurantResponseListener.showLoading();
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
      "restaurant_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.RESTAURANT_DETAILS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      restaurantResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RestaurantsData> baseResponse =
            BaseResponse<RestaurantsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.singleRestaurant != null) {
            restaurantResponseListener
                .setRestaurantData(baseResponse.data?.singleRestaurant);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          restaurantResponseListener.showServerError(baseResponse.message);
        } else {
          restaurantResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          restaurantResponseListener.showServerError(baseResponse.message);
        } else {
          restaurantResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        restaurantResponseListener.showAuthError();
      } else {
        restaurantResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        restaurantResponseListener.hideLoading();
        restaurantResponseListener.showGeneralError();
      } else {
        print('network error');
        restaurantResponseListener.hideLoading();
        restaurantResponseListener.showImageNetworkError();
      }
    }
  }
}
