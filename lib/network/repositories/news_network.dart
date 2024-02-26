import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'package:sporting_club/data/model/news_details_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class NewsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getNewsCategories(NewsResponseListener newsResponseListener) async {
    newsResponseListener.showLoading();
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

    String url = ApiUrls.MAIN_URL + ApiUrls.NEWS_CATEGORIES;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      newsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<CategoriesData> baseResponse =
            BaseResponse<CategoriesData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          newsResponseListener.setCategories(baseResponse.data);
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
        newsResponseListener.showImageNetworkError();
      }
    }
  }

  getNews(int page, String categoryID, bool isNeedLoading,
      NewsResponseListener newsResponseListener) async {
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
      "cat": categoryID.toString(),
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.NEWS;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      newsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<NewsData> baseResponse =
            BaseResponse<NewsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          newsResponseListener.setNews(baseResponse.data);
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

  getInterestsNews(int page, String categoryID, bool isNeedLoading,
      NewsResponseListener newsResponseListener) async {
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
      "cat": categoryID.toString(),
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.NEWS_INTERESTS;
    print(url);

    try {
      final response =
      await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      newsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<NewsData> baseResponse =
        BaseResponse<NewsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          newsResponseListener.setNews(baseResponse.data);
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

  getNewsDetails(
      int id, NewsDetailsResponseListener newsResponseListener) async {
    newsResponseListener.showLoading();

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
      "post_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.NEWS_DETAILS;

    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      newsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<NewsDetailsData> baseResponse =
            BaseResponse<NewsDetailsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.news != null) {
            newsResponseListener.setNews(baseResponse.data?.news);
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
        newsResponseListener.showImageNetworkError();
      }
    }
  }
}
