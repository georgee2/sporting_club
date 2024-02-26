
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_dates.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_times_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_bookings_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_contracts_data.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking_data.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/listeners/RealEstateBookingsResponseListener.dart';
import 'package:sporting_club/network/listeners/RealEstateContractsResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class RealEstateNetwork {
  static int InvalidValues = 404;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int INVALIDREFRESHTOKEN = 401;

  getRealEstateContracts(
      RealEstateContractsResponseListener realEstateContractsResponseListener) async {
    realEstateContractsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_BOOKING_CONTRACTS;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RealEstateContractsData> baseResponse =
        BaseResponse<RealEstateContractsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          realEstateContractsResponseListener.setRealEstateContracts(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        realEstateContractsResponseListener.showAuthError();
      } else {
        realEstateContractsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showImageNetworkError();
      }
    }
  }

  getRealEstateAvailableHours(
      RealEstateContractsResponseListener realEstateContractsResponseListener,String contractTypeId,String bookingDate) async {
    realEstateContractsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    Map<String, dynamic> parameters = {
      'contract_type': contractTypeId,
      'booking_date': bookingDate,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_AVAILABLE_TIMES;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),  headers: headers,body: json.encode(parameters));
      realEstateContractsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RealEstateAvailableTimesData> baseResponse =
        BaseResponse<RealEstateAvailableTimesData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          realEstateContractsResponseListener.setRealEstateAvailableHours(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        realEstateContractsResponseListener.showAuthError();
      } else {
        realEstateContractsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showImageNetworkError();
      }
    }
  }

  getRealEstateAvailableDates(
      RealEstateContractsResponseListener realEstateContractsResponseListener) async {

    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_AVAILABLE_DATES;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      realEstateContractsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RealEstateAvailableDatesData> baseResponse =
        BaseResponse<RealEstateAvailableDatesData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          realEstateContractsResponseListener.setRealEstateAvailableDates(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else {
        realEstateContractsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showImageNetworkError();
      }
    }
  }

  requestRealEstateBooking(
      RealEstateContractsResponseListener realEstateContractsResponseListener,String contractTypeId,String bookingDate,String subContractTypeId,String selectedTime) async {

    realEstateContractsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    Map<String, dynamic> parameters = {
      'contract_type': contractTypeId,
      'booking_date': bookingDate,
      'sub_contract_type': subContractTypeId,
      'booking_slot': selectedTime,
    };
    print(parameters);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_CREATE_BOOKING;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),  headers: headers,body: json.encode(parameters));
      realEstateContractsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        realEstateContractsResponseListener.realEstateBookedSuccessfully();
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {

        realEstateContractsResponseListener.showAuthError();

      } else if (response.statusCode == INVALIDTOKEN) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else {
        realEstateContractsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showImageNetworkError();
      }
    }
  }

  getRealEstateBookings(
      RealEstateBookingsResponseListener realEstateBookingsResponseListener) async {
    realEstateBookingsResponseListener.showLoading();

    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_BOOKINGS;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      realEstateBookingsResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RealEstateBookingsData> baseResponse =
        BaseResponse<RealEstateBookingsData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          realEstateBookingsResponseListener.setRealEstateBookings(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateBookingsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateBookingsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateBookingsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateBookingsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        realEstateBookingsResponseListener.showAuthError();
      } else {
        realEstateBookingsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateBookingsResponseListener.hideLoading();
        realEstateBookingsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateBookingsResponseListener.hideLoading();
        realEstateBookingsResponseListener.showImageNetworkError();
      }
    }
  }

  checkUpcommingBooking(
      RealEstateContractsResponseListener realEstateContractsResponseListener) async {
    realEstateContractsResponseListener.showLoading();
    String token = "";
    if (LocalSettings.token != "") {
      token = LocalSettings.token??"";
      print("token:${token}");
    }

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    print(headers);

    String url = ApiUrls.MAIN_URL +
        ApiUrls.REAL_ESTATE_CHECK_UPCOMMING_BOOKING;
    print(url);

    try {
      final response = await http.get(Uri.parse(url),  headers: headers);
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<RealEstateUpcommingBookingData> baseResponse =
        BaseResponse<RealEstateUpcommingBookingData>.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
          realEstateContractsResponseListener.setRealEstateUpcommingBooking(baseResponse.data,baseResponse.message);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
        BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          realEstateContractsResponseListener.showServerError(baseResponse.message);
        } else {
          realEstateContractsResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        realEstateContractsResponseListener.showAuthError();
      } else {
        realEstateContractsResponseListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showGeneralError();
      } else {
        print('network error');
        realEstateContractsResponseListener.hideLoading();
        realEstateContractsResponseListener.showImageNetworkError();
      }
    }
  }
}