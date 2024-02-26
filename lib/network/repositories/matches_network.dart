import 'package:sporting_club/data/model/match_details_data.dart';
import 'package:sporting_club/data/model/teams_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/MatchDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/MatchesResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class MatchesNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getMatches(
      String dayType, MatchesResponseListener matchesResponseListener) async {
    matchesResponseListener.showLoading();
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
      'day_type': dayType,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.MATCHES;
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      matchesResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TeamsData> baseResponse =
            BaseResponse<TeamsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          matchesResponseListener.setTeams(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchesResponseListener.showServerError(baseResponse.message);
        } else {
          matchesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchesResponseListener.showServerError(baseResponse.message);
        } else {
          matchesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        matchesResponseListener.showAuthError();
      } else {
        matchesResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        matchesResponseListener.hideLoading();
        matchesResponseListener.showGeneralError();
      } else {
        print('network error');
        matchesResponseListener.hideLoading();
        matchesResponseListener.showImageNetworkError();
      }
    }
  }

  getInterestsMatches(
      String dayType, MatchesResponseListener matchesResponseListener) async {
    matchesResponseListener.showLoading();
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
      'day_type': dayType,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.MATCHES_INTERESTS;
    print(url);

    try {
      final response =
      await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      matchesResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<TeamsData> baseResponse =
        BaseResponse<TeamsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          matchesResponseListener.setTeams(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchesResponseListener.showServerError(baseResponse.message);
        } else {
          matchesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchesResponseListener.showServerError(baseResponse.message);
        } else {
          matchesResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        matchesResponseListener.showAuthError();
      } else {
        matchesResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        matchesResponseListener.hideLoading();
        matchesResponseListener.showGeneralError();
      } else {
        print('network error');
        matchesResponseListener.hideLoading();
        matchesResponseListener.showImageNetworkError();
      }
    }
  }

  getMatchDetails(
      String id, MatchDetailsResponseListener matchResponseListener) async {
    matchResponseListener.showLoading();

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
      "match_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.MATCH_DETAILS;

    print(url);

    try {
      final response =
      await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      matchResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<MatchDetailsData> baseResponse =
        BaseResponse<MatchDetailsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.match != null) {
            matchResponseListener.setMatch(baseResponse.data?.match);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchResponseListener.showServerError(baseResponse.message);
        } else {
          matchResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          matchResponseListener.showServerError(baseResponse.message);
        } else {
          matchResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        matchResponseListener.showAuthError();
      } else {
        matchResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        matchResponseListener.hideLoading();
        matchResponseListener.showGeneralError();
      } else {
        print('network error');
        matchResponseListener.hideLoading();
        matchResponseListener.showImageNetworkError();
      }
    }
  }
}
