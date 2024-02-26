import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/data/model/review_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/ReviewResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import '../api_urls.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:convert';

class ReviewNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  setReview(
      String post_id,
      int review_rate,
      String review_message,
      File imageFile,
      bool isUpdate,
      String reviewId,
      bool update_image,
      bool isEvent,
      ReviewResponseListener reviewResponseListener) async {
    reviewResponseListener.showLoading();

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

    Map<String, String> parameters = {
      "post_id": post_id.toString(),
      "review_rate": review_rate.toString(),
      "review_message": review_message,
    };
    if (isUpdate) {
      parameters["comment_id"] = reviewId;
      parameters["update_image"] = update_image.toString();
    }
    print(parameters);
    String url = ApiUrls.MAIN_URL;
    if (isEvent) {
      if (isUpdate) {
        url += ApiUrls.UPDATE_EVENT_REVIEW;
      } else {
        url += ApiUrls.ADD_EVENT_REVIEW;
      }
    } else {
      if (isUpdate) {
        url += ApiUrls.UPDATE_REVIEW;
      } else {
        url += ApiUrls.ADD_REVIEW;
      }
    }
    print(url);

    var uri = Uri.parse(url);

    if (imageFile != null&&imageFile.path.isNotEmpty) {
      var stream =
          new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();
      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('image', stream, length,
          filename: basename(imageFile.path));
      request.files.add(multipartFile);
      request.fields.addAll(parameters);
      request.headers.addAll(headers);

      try {
//        var result = await request.send().then((response) {
//          print(response.statusCode);
//          reviewResponseListener.hideLoading();
//          if (response.statusCode == 200) {
//            print('success');
//            reviewResponseListener.showSuccess();
//          } else if (response.statusCode == UNAUTHORIZED) {
//            reviewResponseListener.showGeneralError();
//          } else if (response.statusCode == INVALIDTOKEN) {
//            reviewResponseListener.showAuthError();
//          } else {
//            reviewResponseListener.showGeneralError();
//          }
//          final respStr =  await response.stream.bytesToString();
//          BaseResponse<ReviewData> baseResponse =
//          BaseResponse<ReviewData>.fromJson(json.decode(respStr));
//          print(baseResponse.data);
//        });

        var result = await request.send();

        reviewResponseListener.hideLoading();
        if (result.statusCode == 200) {
          print('success');
          final respStr = await result.stream.bytesToString();
          BaseResponse<ReviewData> baseResponse =
              BaseResponse<ReviewData>.fromJson(json.decode(respStr));
          if (baseResponse.data != null) {
            if (baseResponse.data?.review != null) {
              reviewResponseListener.showSuccess(baseResponse.data);
            } else {
              reviewResponseListener.showSuccess(ReviewData());
            }
          } else {
            reviewResponseListener.showSuccess(ReviewData());
          }
        } else if (result.statusCode == UNAUTHORIZED) {
          reviewResponseListener.showGeneralError();
        } else if (result.statusCode == INVALIDTOKEN) {
          reviewResponseListener.showAuthError();
        } else {
          reviewResponseListener.showGeneralError();
        }
      } catch (error) {
        print("error: $error" );
        var connectivityResult = await (Connectivity().checkConnectivity());
        if ((connectivityResult == ConnectivityResult.mobile) ||
            (connectivityResult == ConnectivityResult.wifi)) {
          print('ConnectivityResult mobile or wifi');
          reviewResponseListener.hideLoading();
          reviewResponseListener.showGeneralError();
        } else {
          print('network error');
          reviewResponseListener.hideLoading();
          reviewResponseListener.showNetworkError();
        }
      }
    } else {
      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: json.encode(parameters));
        reviewResponseListener.hideLoading();
        print('response' + response.body);
        print('status code: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          print('success');
          BaseResponse<ReviewData> baseResponse =
              BaseResponse<ReviewData>.fromJson(json.decode(response.body));
          if (baseResponse.data != null) {
            if (baseResponse.data?.review != null) {
              reviewResponseListener.showSuccess(baseResponse.data);
            } else {
              reviewResponseListener.showSuccess(ReviewData());
            }
          } else {
            reviewResponseListener.showSuccess(ReviewData());
          }
        } else if (response.statusCode == InvalidValues) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            reviewResponseListener.showServerError(baseResponse.message);
          } else {
            reviewResponseListener.showGeneralError();
          }
        } else if (response.statusCode == UNAUTHORIZED) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            reviewResponseListener.showServerError(baseResponse.message);
          } else {
            reviewResponseListener.showGeneralError();
          }
        } else if (response.statusCode == INVALIDTOKEN) {
          reviewResponseListener.showAuthError();
        } else {
          reviewResponseListener.showGeneralError();
        }
      } catch (error) {
//      print("error: " + error);
        var connectivityResult = await (Connectivity().checkConnectivity());
        if ((connectivityResult == ConnectivityResult.mobile) ||
            (connectivityResult == ConnectivityResult.wifi)) {
          print('ConnectivityResult mobile or wifi');
          reviewResponseListener.hideLoading();
          reviewResponseListener.showGeneralError();
        } else {
          print('network error');
          reviewResponseListener.hideLoading();
          reviewResponseListener.showNetworkError();
        }
      }
    }
  }

  getReview(String post_id, String reviewId, bool isEvent,
      ReviewResponseListener reviewResponseListener) async {
    reviewResponseListener.showLoading();
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
      "post_id": post_id,
      "comment_id": reviewId,
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL;
    if (isEvent) {
      url += ApiUrls.VIEW_EVENT_REVIEW;
    } else {
      url += ApiUrls.VIEW_REVIEW;
    }
    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      reviewResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ReviewData> baseResponse =
            BaseResponse<ReviewData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          reviewResponseListener.setReview(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          reviewResponseListener.showServerError(baseResponse.message);
        } else {
          reviewResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          reviewResponseListener.showServerError(baseResponse.message);
        } else {
          reviewResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        reviewResponseListener.showAuthError();
      } else {
        reviewResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        reviewResponseListener.hideLoading();
        reviewResponseListener.showGeneralError();
      } else {
        print('network error');
        reviewResponseListener.hideLoading();
        reviewResponseListener.showNetworkError();
      }
    }
  }
}
