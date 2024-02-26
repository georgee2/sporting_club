import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:sporting_club/data/model/administratives_data.dart';
import 'package:sporting_club/data/model/complaint_details_data.dart';
import 'package:sporting_club/data/model/complaints_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/AddComplaintResponseListener.dart';
import 'package:sporting_club/network/listeners/ComplaintDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/ComplaintsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import '../api_urls.dart';
import 'dart:convert';

class ComplaintsNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getAdministrativesList(
      AddComplaintResponseListener addComplaintResponseListener) async {
    addComplaintResponseListener.showLoading();
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

    String url = ApiUrls.MAIN_URL + ApiUrls.GET_ADMINISTARTIVES;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      addComplaintResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<AdministrativesData> baseResponse =
            BaseResponse<AdministrativesData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          addComplaintResponseListener.setAdministratives(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          addComplaintResponseListener.showServerError(baseResponse.message);
        } else {
          addComplaintResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          addComplaintResponseListener.showServerError(baseResponse.message);
        } else {
          addComplaintResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        addComplaintResponseListener.showAuthError();
      } else {
        addComplaintResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        addComplaintResponseListener.hideLoading();
        addComplaintResponseListener.showGeneralError();
      } else {
        print('network error');
        addComplaintResponseListener.hideLoading();
        addComplaintResponseListener.showNetworkError();
      }
    }
  }

  addComplaint(String content, File imageFile, String administrativeId,
      AddComplaintResponseListener addComplaintResponseListener) async {
    addComplaintResponseListener.showLoading();

    String token = "";

    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
    }

    Map<String, String> headers = {
//      'Content-type': 'application/json',
//      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    Map<String, String> parameters = {
      "administrative_authority": administrativeId.toString(),
      "complaint_body": content.toString(),
//      'image': new UploadFileInfo(imageFile, "image.jpg"),
    };

    print(parameters);
    String url = ApiUrls.MAIN_URL + ApiUrls.ADD_COMPLAINT;

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


//      FormData formData = new FormData.from(parameters);

      try {
//        Dio dio = Dio();
//        final result =
//        await dio.post(Uri.parse(url),
//            data: formData,
//            options: Options(
//              headers: headers,
//            ));
//        print('response' + result.data.toString());

        var result = await request.send();
        final respStr = await result.stream.bytesToString();
        print(respStr);
        addComplaintResponseListener.hideLoading();
        if (result.statusCode == 200) {
          addComplaintResponseListener.showSuccess();
        } else if (result.statusCode == UNAUTHORIZED) {
          addComplaintResponseListener.showGeneralError();
        } else if (result.statusCode == INVALIDTOKEN) {
          addComplaintResponseListener.showAuthError();
        } else {
          addComplaintResponseListener.showGeneralError();
        }
      } catch (error) {
        print("error: " + error.toString());
        var connectivityResult = await (Connectivity().checkConnectivity());
        if ((connectivityResult == ConnectivityResult.mobile) ||
            (connectivityResult == ConnectivityResult.wifi)) {
          print('ConnectivityResult mobile or wifi');
          addComplaintResponseListener.hideLoading();
          addComplaintResponseListener.showGeneralError();
        } else {
          print('network error');
          addComplaintResponseListener.hideLoading();
          addComplaintResponseListener.showNetworkError();
        }
      }
    } else {
      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: parameters);
        addComplaintResponseListener.hideLoading();
        print('response' + response.body);
        print('status code: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          print('success');
          addComplaintResponseListener.showSuccess();
        } else if (response.statusCode == InvalidValues) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            addComplaintResponseListener.showServerError(baseResponse.message);
          } else {
            addComplaintResponseListener.showGeneralError();
          }
        } else if (response.statusCode == UNAUTHORIZED) {
          BaseResponse baseResponse =
              BaseResponse.fromJson(json.decode(response.body));
          if (baseResponse.message != null) {
            addComplaintResponseListener.showServerError(baseResponse.message);
          } else {
            addComplaintResponseListener.showGeneralError();
          }
        } else if (response.statusCode == INVALIDTOKEN) {
          addComplaintResponseListener.showAuthError();
        } else {
          addComplaintResponseListener.showGeneralError();
        }
      } catch (error) {
//      print("error: " + error);
        var connectivityResult = await (Connectivity().checkConnectivity());
        if ((connectivityResult == ConnectivityResult.mobile) ||
            (connectivityResult == ConnectivityResult.wifi)) {
          print('ConnectivityResult mobile or wifi');
          addComplaintResponseListener.hideLoading();
          addComplaintResponseListener.showGeneralError();
        } else {
          print('network error');
          addComplaintResponseListener.hideLoading();
          addComplaintResponseListener.showNetworkError();
        }
      }
    }
  }

  getComplaints(int page, bool isNeedLoading,
      ComplaintsResponseListener complaintsResponseListener) async {
    if (isNeedLoading) {
      complaintsResponseListener.showLoading();
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
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.COMPLAINTS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      complaintsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ComplaintsData> baseResponse =
            BaseResponse<ComplaintsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          complaintsResponseListener.setComplaints(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintsResponseListener.showServerError(baseResponse.message);
        } else {
          complaintsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintsResponseListener.showServerError(baseResponse.message);
        } else {
          complaintsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        complaintsResponseListener.showAuthError();
      } else {
        complaintsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        complaintsResponseListener.hideLoading();
        complaintsResponseListener.showGeneralError();
      } else {
        print('network error');
        complaintsResponseListener.hideLoading();
        if (page == 1) {
          complaintsResponseListener.showImageNetworkError();
        } else {
          complaintsResponseListener.showNetworkError();
        }
      }
    }
  }

  getComplaintDetails(int id,
      ComplaintDetailsResponseListener complaintDetailsResponseListener) async {
    complaintDetailsResponseListener.showLoading();

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
      "complaint_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.VIEW_COMPLAINT;

    print(url);

    try {
      final response =
          await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      complaintDetailsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<ComplaintDetailsData> baseResponse =
            BaseResponse<ComplaintDetailsData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          if (baseResponse.data?.complaint != null) {
            complaintDetailsResponseListener
                .setComplaint(baseResponse.data?.complaint);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintDetailsResponseListener
              .showServerError(baseResponse.message);
        } else {
          complaintDetailsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintDetailsResponseListener
              .showServerError(baseResponse.message);
        } else {
          complaintDetailsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        complaintDetailsResponseListener.showAuthError();
      } else {
        complaintDetailsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        complaintDetailsResponseListener.hideLoading();
        complaintDetailsResponseListener.showGeneralError();
      } else {
        print('network error');
        complaintDetailsResponseListener.hideLoading();
        complaintDetailsResponseListener.showImageNetworkError();
      }
    }
  }
  removeComplaintDetails(int id, BuildContext context ,
      ComplaintDetailsResponseListener? complaintDetailsResponseListener,  ComplaintsResponseListener? complaintsResponseListener) async {

    if(complaintDetailsResponseListener!=null){
      complaintDetailsResponseListener.showLoading();
    }
    if(complaintsResponseListener!=null){
      complaintsResponseListener.showLoading();
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
      "complaint_id": id.toString(),
    };

    print(parameters);

    String url = ApiUrls.MAIN_URL + ApiUrls.DISMISS_COMPLAINT;

    print(url);

    try {
      final response =
      await http.post(Uri.parse(url),  headers: headers, body: json.encode(parameters));
      complaintDetailsResponseListener==null?  complaintsResponseListener?.hideLoading():complaintDetailsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        if(complaintsResponseListener!=null){
          complaintsResponseListener.clearComplaints();
          getComplaints(1, true, complaintsResponseListener);
        }else{
          Navigator.of(context).pop("removed");
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintDetailsResponseListener==null?   complaintsResponseListener?.showServerError(baseResponse.message):
          complaintDetailsResponseListener.showServerError(baseResponse.message);
        } else {
          complaintDetailsResponseListener==null? complaintsResponseListener?.showGeneralError():complaintDetailsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          complaintDetailsResponseListener==null?
          complaintsResponseListener?.showServerError(baseResponse.message):   complaintDetailsResponseListener
              .showServerError(baseResponse.message);
        } else {
          complaintDetailsResponseListener==null? complaintsResponseListener?.showGeneralError(): complaintDetailsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        complaintDetailsResponseListener==null? complaintsResponseListener?.showAuthError(): complaintDetailsResponseListener.showAuthError();
      } else {
        complaintDetailsResponseListener==null?  complaintsResponseListener?.showGeneralError(): complaintDetailsResponseListener.showGeneralError();
      }
    } catch (error) {
//      print("error: " + error);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        complaintDetailsResponseListener==null?   complaintsResponseListener?.hideLoading(): complaintDetailsResponseListener.hideLoading();
        complaintDetailsResponseListener==null?   complaintsResponseListener?.showGeneralError(): complaintDetailsResponseListener.showGeneralError();
      } else {
        print('network error');
        complaintDetailsResponseListener==null?  complaintsResponseListener?.hideLoading():complaintDetailsResponseListener.hideLoading();
        complaintDetailsResponseListener==null? complaintsResponseListener?.showImageNetworkError():complaintDetailsResponseListener.showImageNetworkError();
      }
    }
  }

}
