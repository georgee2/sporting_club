import 'package:sporting_club/data/model/activity_data.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'package:sporting_club/data/model/service_details_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/offer_details_data.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/services_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/model/trips/trips_data_activity.dart';
import 'package:sporting_club/data/model/trips/trips_interests_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/ActivitiesResponseListener.dart';
import 'package:sporting_club/network/listeners/OfferServiceDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/OffersServicesResponseListener.dart';
import 'package:sporting_club/network/listeners/TripsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class OffersServicesNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getOffersCategories(bool _isOffers,
      OffersServicesResponseListener offersResponseListener) async {
    offersResponseListener.showLoading();
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

    String url = "";
    _isOffers
        ? url = ApiUrls.MAIN_URL + ApiUrls.OFFERS_CATEGORIES
        : url = ApiUrls.MAIN_URL + ApiUrls.SERVICES_CATEGORIES;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      offersResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ServiceCategoriesData> baseResponse =
        BaseResponse<ServiceCategoriesData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          offersResponseListener.setCategories(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        offersResponseListener.showAuthError();
      } else {
        offersResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        offersResponseListener.hideLoading();
        offersResponseListener.showGeneralError();
      } else {
        print('network error');
        offersResponseListener.hideLoading();
        offersResponseListener.showImageNetworkError();
      }
    }
  }

  getCategories(bool _isOffers,
      OffersServicesResponseListener offersResponseListener) async {
    offersResponseListener.showLoading();
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

    String url = "";
    _isOffers
        ? url = ApiUrls.MAIN_URL + ApiUrls.OFFERS_CATEGORIES
        : url = ApiUrls.MAIN_URL + ApiUrls.SERVICES_CATEGORIES;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      offersResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        if(_isOffers){
          BaseResponse<CategoriesData> baseResponse =
          BaseResponse<CategoriesData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
            offersResponseListener.setOffersCategories(baseResponse.data);
          }
        }else{
          BaseResponse<ServiceCategoriesData> baseResponse =
          BaseResponse<ServiceCategoriesData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
            offersResponseListener.setCategories(baseResponse.data);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        offersResponseListener.showAuthError();
      } else {
        offersResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        offersResponseListener.hideLoading();
        offersResponseListener.showGeneralError();
      } else {
        print('network error');
        offersResponseListener.hideLoading();
        offersResponseListener.showImageNetworkError();
      }
    }
  }

  getOffersOrServices(
      bool _isOffers,
      int page,
      String categoryID,
      bool isNeedLoading,
      OffersServicesResponseListener offersResponseListener) async {
    if (isNeedLoading) {
      offersResponseListener.showLoading();
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

    Map<String, dynamic> parameters = {
      'page': page,
      'limit': 10,
      "cat": categoryID.toString(),
    };
    print(parameters);
    String url = "";
    _isOffers
        ? url = ApiUrls.MAIN_URL + ApiUrls.OFFERS
        : url = ApiUrls.MAIN_URL + ApiUrls.SERVICES;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      offersResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        if (_isOffers) {
          BaseResponse<OffersData> baseResponse =
              BaseResponse<OffersData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.offers != null) {
              offersResponseListener.setData(baseResponse.data?.offers);
            }
          }
        } else {
          BaseResponse<ServicesData> baseResponse =
              BaseResponse<ServicesData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.services != null) {
              offersResponseListener.setData(baseResponse.data?.services);
            }
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offersResponseListener.showServerError(baseResponse.message);
        } else {
          offersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        offersResponseListener.showAuthError();
      } else {
        offersResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        offersResponseListener.hideLoading();
        offersResponseListener.showGeneralError();
      } else {
        print('network error');
        offersResponseListener.hideLoading();
        if (page == 1) {
          offersResponseListener.showImageNetworkError();
        } else {
          offersResponseListener.showNetworkError();
        }
      }
    }
  }

  getOffersOrServicesDetails(bool _isOffers, int id,
      OfferServiceDetailsResponseListener offerServiceResponseListener) async {
    offerServiceResponseListener.showLoading();

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

    String key = _isOffers ? "promotion_id" : "service_id";
    Map<String, dynamic> parameters = {
      key: id.toString(),
    };

    print(parameters);

    String url = "";
    _isOffers
        ? url = ApiUrls.MAIN_URL + ApiUrls.OFFER_DETAILS
        : url = ApiUrls.MAIN_URL + ApiUrls.SERVICE_DETAILS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      offerServiceResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        if (_isOffers) {
          BaseResponse<OfferDetailsData> baseResponse =
              BaseResponse<OfferDetailsData>.fromJson(
                  json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.offer != null) {
              offerServiceResponseListener.setData(baseResponse.data?.offer);
            }
          }
        } else {
          BaseResponse<ServiceDetailsData> baseResponse =
              BaseResponse<ServiceDetailsData>.fromJson(
                  json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.service != null) {
              offerServiceResponseListener.setData(baseResponse.data?.service);
            }
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offerServiceResponseListener.showServerError(baseResponse.message);
        } else {
          offerServiceResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offerServiceResponseListener.showServerError(baseResponse.message);
        } else {
          offerServiceResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        offerServiceResponseListener.showAuthError();
      } else {
        offerServiceResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        offerServiceResponseListener.hideLoading();
        offerServiceResponseListener.showGeneralError();
      } else {
        print('network error');
        offerServiceResponseListener.hideLoading();
        offerServiceResponseListener.showImageNetworkError();
      }
    }
  }

  interestOfferOrServices(bool _isOffers, int id,
      OfferServiceDetailsResponseListener offerServiceResponseListener) async {
    offerServiceResponseListener.showLoading();

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

    String key = _isOffers ? "promotion_id" : "service_id";
    Map<String, dynamic> parameters = {
      key: id.toString(),
    };

    print(parameters);

    String url = "";
    _isOffers
        ? url = ApiUrls.MAIN_URL + ApiUrls.OFFER_INTEREST
        : url = ApiUrls.MAIN_URL + ApiUrls.SERVICE_INTEREST;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      offerServiceResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        offerServiceResponseListener.showInterestedSuccessfully();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offerServiceResponseListener.showServerError(baseResponse.message);
        } else {
          offerServiceResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          offerServiceResponseListener.showServerError(baseResponse.message);
        } else {
          offerServiceResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        offerServiceResponseListener.showAuthError();
      } else {
        offerServiceResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        offerServiceResponseListener.hideLoading();
        offerServiceResponseListener.showGeneralError();
      } else {
        print('network error');
        offerServiceResponseListener.hideLoading();
        offerServiceResponseListener.showNetworkError();
      }
    }
  }


  getActivities(
      ActivitiesResponseListener activitiesResponseListener) async {
    activitiesResponseListener.showLoading();
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

    String url = ApiUrls.MAIN_URL + ApiUrls.GET_Activites;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),  headers: headers);
     // activitiesResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');

          BaseResponse<ActivityData> baseResponse =
          BaseResponse<ActivityData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
//          List<Trip> trips = [];
//trips.add(Trip(
//    waiting_list_count: 0,
//    available_seats: 99,
//    id: 39,
//    category: 0,
//    name: "حجز رحلة الاهرامات",
//    start_date: "02-10-2020",
//    end_date: "09-10-2020",
//    booking_start_date: "07-09-2020",
//    booking_end_date: "14-09-2020",
//    seats_count: 100,
    //));
           getBookingTrips(baseResponse.data, activitiesResponseListener);
           // activitiesResponseListener.setData(baseResponse.data,trips);
          }


      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          activitiesResponseListener.showServerError(baseResponse.message);
        } else {
          activitiesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          activitiesResponseListener.showServerError(baseResponse.message);
        } else {
          activitiesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        activitiesResponseListener.showAuthError();
      } else {
        activitiesResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        activitiesResponseListener.hideLoading();
        activitiesResponseListener.showGeneralError();
      } else {
        print('network error');
        activitiesResponseListener.hideLoading();
        activitiesResponseListener.showImageNetworkError();
      }
    }
  }

  getBookingTrips(ActivityData? activityData,
      ActivitiesResponseListener tripsResponseListener) async {

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
        ApiUrls.GET_BOOKING_TRIPS ;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      tripsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TripsDataActivity> baseResponse =
        BaseResponse<TripsDataActivity>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          tripsResponseListener.setData(activityData,baseResponse.data?.bookings);
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

}
