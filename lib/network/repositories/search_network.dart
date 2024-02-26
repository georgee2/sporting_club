import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/events_data.dart';
import 'package:sporting_club/data/model/news_search_data.dart';
import 'package:sporting_club/data/model/offer_details_data.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/services_data.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/OfferServiceDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/OffersServicesResponseListener.dart';
import 'package:sporting_club/network/listeners/SearchResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class SearchNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  searchOffers(String search, int page, bool isNeedLoading,
      SearchResponseListener offersResponseListener) async {
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
      'search': search,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SEARCH_OFFERS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      offersResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<OffersData> baseResponse =
            BaseResponse<OffersData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.offers != null) {
            offersResponseListener.setData(baseResponse.data?.offers);
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

  searchServices(String search, int page, bool isNeedLoading,
      SearchResponseListener servicesResponseListener) async {
    if (isNeedLoading) {
      servicesResponseListener.showLoading();
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
      'search': search,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SEARCH_SERVICES;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      servicesResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ServicesData> baseResponse =
            BaseResponse<ServicesData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.services != null) {
            servicesResponseListener.setData(baseResponse.data?.services);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          servicesResponseListener.showServerError(baseResponse.message);
        } else {
          servicesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          servicesResponseListener.showServerError(baseResponse.message);
        } else {
          servicesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        servicesResponseListener.showAuthError();
      } else {
        servicesResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        servicesResponseListener.hideLoading();
        servicesResponseListener.showGeneralError();
      } else {
        print('network error');
        servicesResponseListener.hideLoading();
        if (page == 1) {
          servicesResponseListener.showImageNetworkError();
        } else {
          servicesResponseListener.showNetworkError();
        }
      }
    }
  }

  searchEvents(String search, int page, bool isNeedLoading,
      SearchResponseListener servicesResponseListener) async {
    if (isNeedLoading) {
      servicesResponseListener.showLoading();
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
      'search': search,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SEARCH_EVENTS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      servicesResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<EventsData> baseResponse =
            BaseResponse<EventsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.events != null) {
            servicesResponseListener.setEvents(baseResponse.data?.events);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          servicesResponseListener.showServerError(baseResponse.message);
        } else {
          servicesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          servicesResponseListener.showServerError(baseResponse.message);
        } else {
          servicesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        servicesResponseListener.showAuthError();
      } else {
        servicesResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        servicesResponseListener.hideLoading();
        servicesResponseListener.showGeneralError();
      } else {
        print('network error');
        servicesResponseListener.hideLoading();
        if (page == 1) {
          servicesResponseListener.showImageNetworkError();
        } else {
          servicesResponseListener.showNetworkError();
        }
      }
    }
  }

  searchNews(String search, int page, String search_from,bool isNeedLoading,
      SearchResponseListener newsResponseListener) async {
    if (isNeedLoading) {
      newsResponseListener.showLoading();
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
      'search': search,
      'search_from': search_from,

    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.SEARCH_NEWS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      newsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<NewsSearchData> baseResponse =
            BaseResponse<NewsSearchData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.news != null) {
            newsResponseListener.setData(baseResponse.data?.news);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          newsResponseListener.showServerError(baseResponse.message);
        } else {
          newsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          newsResponseListener.showServerError(baseResponse.message);
        } else {
          newsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        newsResponseListener.showAuthError();
      } else {
        newsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        newsResponseListener.hideLoading();
        newsResponseListener.showGeneralError();
      } else {
        print('network error');
        newsResponseListener.hideLoading();
        if (page == 1) {
          newsResponseListener.showImageNetworkError();
        } else {
          newsResponseListener.showNetworkError();
        }
      }
    }
  }

  searchTrips(String search, int page, bool isNeedLoading,
      SearchResponseListener tripsResponseListener) async {
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
        "?query=" +
        search +
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
        if (page == 1) {
          tripsResponseListener.showImageNetworkError();
        } else {
          tripsResponseListener.showNetworkError();
        }
      }
    }
  }

}
