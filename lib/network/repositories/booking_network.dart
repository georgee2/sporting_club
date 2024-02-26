import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/booking_rooms.dart';
import 'package:sporting_club/data/model/trips/booking_seat_types.dart';
import 'package:sporting_club/data/model/trips/follow_member.dart';
import 'package:sporting_club/data/model/trips/guest.dart';
import 'package:sporting_club/data/model/trips/offline_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';
import 'package:sporting_club/data/model/trips/other_member.dart';
import 'package:sporting_club/data/model/trips/seat_type.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_room_type.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/data/response/booking_base_response.dart';
import 'package:sporting_club/delegates/online_payment_delegate.dart';
import 'package:sporting_club/network/listeners/FollowMembersResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentTypeResponseListener.dart';
import 'package:sporting_club/network/listeners/RealEstateContractsResponseListener.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:http/http.dart' as http;
import '../api_urls.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class BookingNetwork {
  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 401;
  static int NOT_ACCEPTABLE = 406;

  getSeatsNumber( int tripId,
      SeatsNumberResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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


        ApiUrls.GETAVALABLESEATS;
    print(url);

    Map<String, dynamic> parameters = {
      'trip_id': tripId,
    };
    print(parameters);


    try {
      final response =
      await http.post(Uri.parse(url),body: json.encode(parameters),  headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BookingBaseResponse<BookingRequest> baseResponse =
        BookingBaseResponse<BookingRequest>.fromJson(
            json.decode(response.body));
        if (baseResponse.data != null) {
         seatsNumberListener.showSuccessCount(baseResponse.data?.count.toString());
        }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      }
      else if (response.statusCode == NOT_ACCEPTABLE) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      }
      else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        }
        else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        seatsNumberListener.showAuthError();
        // BookingBaseResponse baseResponse = BookingBaseResponse.fromJson(json.decode(response.body));
        // if (baseResponse.error != null) {
        //   seatsNumberListener.showServerError(baseResponse.error);
        // }
        // else {
        //   seatsNumberListener.showAuthError();
        // }
      } else {
        seatsNumberListener.showGeneralError();

      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }
  setSeatsNumber(int seatsCount, int tripId,
      SeatsNumberResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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
        "/" +
        tripId.toString() +
        "/" +
        ApiUrls.BOOKING_REQUEST_CREATE;
    print(url);

    Map<String, dynamic> parameters = {
      'seatsCount': seatsCount.toString(),
    };
    print(parameters);

    try {
      final response =
          await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BookingBaseResponse<BookingRequest> baseResponse =
            BookingBaseResponse<BookingRequest>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          seatsNumberListener.showSuccess(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      }
      else if (response.statusCode == NOT_ACCEPTABLE) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      }
      else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        }
        else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        seatsNumberListener.showAuthError();
      } else {
        seatsNumberListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }

  requestPayment(
      List<TripRoomType> _selectedRoomsList,
      List<SeatType> _selectedSeatsList,
      List<String> _selectedIDsList,
      List<String> nonFollowersIdsList,
      Trip _trip,
      bool isOffline,
      BookingRequest _bookingRequest,
      String _email,
      String phone1,
      String phone2,
      String phone3,
      String deposite,
      List<Guest> guests,int childrenSeatsNumbers,
      PaymentTypeResponseListener paymentTypeListener) async {
    paymentTypeListener.showLoading();
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
        "/" +
        _trip.id.toString() +
        "/" +
        ApiUrls.BOOKING_CREATE;
    print(url);

    Map<String, dynamic> parameters = _getRequestParameters(
        _selectedRoomsList,
        _selectedSeatsList,
        _selectedIDsList,
        nonFollowersIdsList,
        isOffline,
        _bookingRequest,
        _email,
        phone1, phone2, phone3,
        deposite,
        guests,
        childrenSeatsNumbers,
        _trip.comment);
    print("BOOKING parameters $parameters");

    try {
      final response =
          await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      paymentTypeListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        if (isOffline) {
          BookingBaseResponse<OfflinePayment> baseResponse =
              BookingBaseResponse<OfflinePayment>.fromJson(
                  json.decode(response.body));
          if (baseResponse.data != null) {
            paymentTypeListener.showSuccessOffline(baseResponse.data);
          }
        } else {
          BookingBaseResponse<OnlinePayment> baseResponse =
              BookingBaseResponse<OnlinePayment>.fromJson(
                  json.decode(response.body));
          if (baseResponse.data != null) {
            paymentTypeListener.showSuccessOnline(baseResponse.data);
          }
        }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        paymentTypeListener.showAuthError();
      } else {
        paymentTypeListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showGeneralError();
      } else {
        print('network error');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showNetworkError();
      }
    }
  }

  Map<String, dynamic> _getRequestParameters(
    List<TripRoomType> _selectedRoomsList,
    List<SeatType> _selectedSeatsList,
    List<String> _selectedIDsList,
        List<String> nonFollowersIdsList,
    bool isOffline,
    BookingRequest _bookingRequest,
    String _email,
      String phone1,
      String phone2,
      String phone3,
    var deposite, List<Guest> guests,
      int childrenSeatsNumbers,
      String? comment
  ) {
    List<Map> rooms =  [];
    for (TripRoomType roomType in _selectedRoomsList) {
      BookingRoom room = BookingRoom(
          room_type: roomType.id,
          room_view: roomType.selectedRoomView?.id,
          capacity: roomType.selectedCapacity,
        guestsCount: roomType.guestCount,
        isContainGuests:  roomType.isContainGuests??false,
      );
      rooms.add(room.toJson());
    }

    List<Map> seats =  [];
    for (SeatType seatType in _selectedSeatsList) {
      BookingSeatTypes seat = BookingSeatTypes(seatType: seatType.id, name: seatType.childName);
      seats.add(seat.toJson());
    }
    Map<String, dynamic> parameters;
    parameters = {
      "bookingRequest": _bookingRequest.id,
      "mainMemberEmail": _email,
      "phone1": phone1,
      "phone2": phone2,
      "phone3": phone3,
      "paymentType": isOffline ? 0 : 1,
      "membership_ids": _selectedIDsList,
      "membership_ids_non_followers":nonFollowersIdsList,
      "booking_rooms": rooms,
      "bookingSeatTypes": seats,

      "has_child": _selectedSeatsList.length > 0 ? true : false,
    };
    if (deposite != null&&deposite.toString().isNotEmpty) {
      parameters["deposite"] = deposite;
      parameters["payDeposite"] = true;

    }
    if (guests  != null&&guests.length !=0) {
      parameters["booking_guests"] = guests.map((e) => e.toJson()).toList() ;
    }
    if (childrenSeatsNumbers != 0) {
      parameters["childrenSeatsCount"] = childrenSeatsNumbers;
      parameters["hasChildrenSeats"] = true;

    }else{
      parameters["hasChildrenSeats"] = false;

    }
    if (comment != null&&comment!="") {
      parameters["comment"] = comment;
    }
    print(parameters);
    return parameters;
  }

  setWaitnigSeatsNumber(int seatsCount, int tripId,
      SeatsNumberResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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
        "/" +
        tripId.toString() +
        "/" +
        ApiUrls.BOOKING_WAITING_CREATE;
    print(url);

    Map<String, dynamic> parameters = {
      'number_of_seats': seatsCount.toString(),
    };
    print(parameters);

    try {
      final response =
          await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        seatsNumberListener.showSuccessWaiting();
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        seatsNumberListener.showAuthError();
      } else {
        seatsNumberListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }

  requestOnlinePayment(double total, String email,
      PaymentTypeResponseListener paymentTypeListener) async {
    paymentTypeListener.showLoading();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "x-api-key": "W18rIHdM.ltqeiaunygchnWxb1S94p4lBgNY0PSEC",
    };
    print(headers);

    String url = "https://develop.xpay.app/api/payments/pay/";
    print(url);

    Map<String, dynamic> parameters = _getOnlineRequestParameters(total, email);
    print(parameters);

    try {
      final response =
          await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      paymentTypeListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          paymentTypeListener.showServerError(baseResponse.error);
        } else {
          paymentTypeListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        paymentTypeListener.showAuthError();
      } else {
        paymentTypeListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showGeneralError();
      } else {
        print('network error');
        paymentTypeListener.hideLoading();
        paymentTypeListener.showNetworkError();
      }
    }
  }

  Map<String, dynamic> _getOnlineRequestParameters(double total, String email) {
    Map<String, dynamic> userParameters = {
      "name": LocalSettings.user?.user_name ?? "",
      "email": email,
      "phone_number": "+2" + (LocalSettings.user?.phone ?? ""),
    };
    print(userParameters);

    Map<String, dynamic> parameters = {
      "amount_piasters": total,
      "billing_data": userParameters,
      "member_id": LocalSettings.user?.membership_no ,
      "amountless_bill_template_id": 1,
    };
    print(parameters);
    return parameters;
  }

  cancelTrip(
      int tripId, SeatsNumberResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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
        ApiUrls.GET_BOOKING_TRIPS +
        "/" +
        tripId.toString() +
        "/" +
        ApiUrls.Cancel_BOOKING_TRIPS;
    print(url);
    Map<String, dynamic> parameters = {
      'id': tripId.toString(),
    };
    print(parameters);

    try {
      final response =
          await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
//        BookingBaseResponse<BookingRequest> baseResponse =
//        BookingBaseResponse<BookingRequest>.fromJson(
//            json.decode(response.body));
        // if (baseResponse.data != null) {
        seatsNumberListener.showSuccessCancel();
        //  }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
            BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        seatsNumberListener.showAuthError();
      } else {
        seatsNumberListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }

  getFollowMembers(FollowMembersResponseListener followMembersResponseListener,
      trip_id) async {
    followMembersResponseListener.showLoading();
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

    String url = ApiUrls.BOOKING_MAIN_URL + ApiUrls.FOLLOW_MEMBERS;
    print(url);

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode({"trip_id": trip_id}));
      followMembersResponseListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BaseResponse<FollowMembersData> baseResponse =
            BaseResponse<FollowMembersData>.fromJson(
                json.decode(response.body));
        if (baseResponse.data != null) {
          print('success2');

          followMembersResponseListener.setFollowMembers(baseResponse.data);
        }
      } else if (response.statusCode == InvalidValues) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          followMembersResponseListener.showServerError(baseResponse.message);
        } else {
          print('success3');

          followMembersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BaseResponse baseResponse =
            BaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.message != null) {
          followMembersResponseListener.showServerError(baseResponse.message);
        } else {
          print('success4');

          followMembersResponseListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        followMembersResponseListener.showAuthError();
      } else {
        print('success5');

        followMembersResponseListener.showGeneralError();
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        followMembersResponseListener.hideLoading();
        followMembersResponseListener.showGeneralError();
      } else {
        print('network error');
        followMembersResponseListener.hideLoading();
        // followMembersResponseListener.showImageNetworkError();
      }
    }
  }

  expireTrip(
      int tripId, SeatsNumberResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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
        ApiUrls.GET_BOOKING_TRIPS +
        "/" +
        ApiUrls.Request_BOOKING_TRIPS+"/"+
        tripId.toString() +
        "/" +
        ApiUrls.EXPIRE_BOOKING_TRIPS;
    print(url);
    Map<String, dynamic> parameters = {
      'id': tripId.toString(),
    };
    print(parameters);

    try {
      final response =
      await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
//        BookingBaseResponse<BookingRequest> baseResponse =
//        BookingBaseResponse<BookingRequest>.fromJson(
//            json.decode(response.body));
        // if (baseResponse.data != null) {
        seatsNumberListener.showSuccessCancel();
        //  }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        seatsNumberListener.showAuthError();
      } else {
        seatsNumberListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }



  getMemberNameById(
      String memberId,int tripId,  FollowMembersResponseListener seatsNumberListener) async {
    seatsNumberListener.showLoading();
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
        ApiUrls.GET_MEMBER_NAME_BY_ID ;
    print(url);
    Map<String, dynamic> parameters = {
      'member_id': memberId,
      "trip_id":tripId
    };
    print(parameters);
    seatsNumberListener.showLoading();

    try {
      final response =
      await http.post(Uri.parse(url),  body: json.encode(parameters), headers: headers);
      seatsNumberListener.hideLoading();
      print('response' + response.body);
      print('status code: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('success');
        BookingBaseResponse<OtherMembers> baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.data != null) {
        seatsNumberListener.showSuccessMemberName(baseResponse.data, memberId);
         }
      } else if (response.statusCode == InvalidValues) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == VALIDATION_ERROR) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == UNAUTHORIZED) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        } else {
          seatsNumberListener.showGeneralError();
        }
      } else if (response.statusCode == INVALIDTOKEN) {
        BookingBaseResponse baseResponse =
        BookingBaseResponse.fromJson(json.decode(response.body));
        if (baseResponse.error != null) {
          seatsNumberListener.showServerError(baseResponse.error);
        }else{
          seatsNumberListener.showAuthError();
        }
      } else {
        seatsNumberListener.showGeneralError();
      }
    } catch (error) {
      print("error: " + error.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showGeneralError();
      } else {
        print('network error');
        seatsNumberListener.hideLoading();
        seatsNumberListener.showNetworkError();
      }
    }
  }

}
