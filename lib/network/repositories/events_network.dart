import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/event_details_data.dart';
import 'package:sporting_club/data/model/events_data.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'package:sporting_club/data/model/news_details_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/EventDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/EventsResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class EventsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getEvents(String filterDate, int page, bool isNeedLoading,
      EventsResponseListener eventsResponseListener) async {
    if (isNeedLoading) {
      eventsResponseListener.showLoading();
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
      'filter_date': filterDate,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.EVENTS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      eventsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<EventsData> baseResponse =
            BaseResponse<EventsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          eventsResponseListener.setEvents(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventsResponseListener.showServerError(baseResponse.message);
        } else {
          eventsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventsResponseListener.showServerError(baseResponse.message);
        } else {
          eventsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        eventsResponseListener.showAuthError();
      } else {
        eventsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        eventsResponseListener.hideLoading();
        eventsResponseListener.showGeneralError();
      } else {
        print('network error');
        eventsResponseListener.hideLoading();
        if (page == 1) {
          eventsResponseListener.showImageNetworkError();
        } else {
          eventsResponseListener.showNetworkError();
        }
      }
    }
  }

  getInterestsEvents(String filterDate, int page, bool isNeedLoading,
      EventsResponseListener eventsResponseListener) async {
    if (isNeedLoading) {
      eventsResponseListener.showLoading();
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
      "filter_date": filterDate,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.EVENTS_INTERESTS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      eventsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<EventsData> baseResponse =
            BaseResponse<EventsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          eventsResponseListener.setEvents(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventsResponseListener.showServerError(baseResponse.message);
        } else {
          eventsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventsResponseListener.showServerError(baseResponse.message);
        } else {
          eventsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        eventsResponseListener.showAuthError();
      } else {
        eventsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        eventsResponseListener.hideLoading();
        eventsResponseListener.showGeneralError();
      } else {
        print('network error');
        eventsResponseListener.hideLoading();
        if (page == 1) {
          eventsResponseListener.showImageNetworkError();
        } else {
          eventsResponseListener.showNetworkError();
        }
      }
    }
  }

  getEventDetails(
      String id, EventDetailsResponseListener eventResponseListener) async {
    eventResponseListener.showLoading();

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
      "event_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.EVENT_DETAILS;

    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      eventResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<EventDetailsData> baseResponse =
            BaseResponse<EventDetailsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.event != null) {
            eventResponseListener.setEvent(baseResponse.data?.event);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventResponseListener.showServerError(baseResponse.message);
        } else {
          eventResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventResponseListener.showServerError(baseResponse.message);
        } else {
          eventResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        eventResponseListener.showAuthError();
      } else {
        eventResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        eventResponseListener.hideLoading();
        eventResponseListener.showGeneralError();
      } else {
        print('network error');
        eventResponseListener.hideLoading();
        eventResponseListener.showImageNetworkError();
      }
    }
  }

  reactEvent(
      String id, bool going, bool interested, bool notInterested, EventDetailsResponseListener eventResponseListener) async {

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
      "event_id": id.toString(),
      "interested" : interested,
      "not_interested" : notInterested,
      "going" : going,
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.EVENT_REACT;

    print(url);

    try {
      final response =
      await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventResponseListener.showServerError(baseResponse.message);
        } else {
          eventResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          eventResponseListener.showServerError(baseResponse.message);
        } else {
          eventResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        eventResponseListener.showAuthError();
      } else {
        eventResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        eventResponseListener.showGeneralError();
      } else {
        print('network error');
        eventResponseListener.showNetworkError();
      }
    }
  }
}
