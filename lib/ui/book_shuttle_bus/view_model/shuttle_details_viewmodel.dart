import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_list_response.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

class ShuttleDetailsViewModel extends ChangeNotifier with BaseViewModel {
  ShuttleBusNetwork _busNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  BuildContext? mcurrentContext;

  ShuttleDetailsViewModel(this._busNetwork, currentContext) {
    mcurrentContext = currentContext;
    print("init ShuttleViewModel");
  }

  ShuttleDetails shuttleDetails = ShuttleDetails();

  getShuttleDetails({required String shuttleId}) async {
    print("init getShuttlePackages");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttleDetails> baseResponse =
          await _busNetwork.getShuttleDetails(shuttleId: shuttleId);
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          shuttleDetails = baseResponse.data ?? ShuttleDetails();
        }
        stopLoading();
      } else {
        if (baseResponse.statusCode == InvalidValues) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == UNAUTHORIZED) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == INVALIDTOKEN) {
          showAuthError();
        } else if (baseResponse.statusCode == NO_NETWORK) {
          showNetworkError();
          } else {
          showGeneralError();
        }
        stopLoading(isConnected: false);
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        showGeneralError();
      } else {
        print('network error');
      }
      stopLoading(isConnected: false);
    }
  }

  List<Shuttle> shuttleList = [];
  int bookingTotal = 0;

  getShuttleList(int page) async {
    print("init getShuttlePackages");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttleListResponse> baseResponse =
          await _busNetwork.getShuttleList(page);
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          bookingTotal = int.parse(
              (baseResponse.data?.bookingTotal?.isEmpty ?? true)
                  ? "0"
                  : (baseResponse.data?.bookingTotal ?? "0"));
          shuttleList = baseResponse.data?.shuttles ?? [];
          noData = shuttleList.isEmpty;
        }
        stopLoading(noDataVal: noData);
      } else {
        if (baseResponse.statusCode == InvalidValues) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == UNAUTHORIZED) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == INVALIDTOKEN) {
          showAuthError();
        } else if (baseResponse.statusCode == NO_NETWORK) {
          if (page == 1) {
            stopLoading(isConnected: false);
          } else {
            stopLoading();
            showNetworkError();
          }
        } else {
          showGeneralError();
          stopLoading( );
        }
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        showGeneralError();
        stopLoading();
      } else {
        print('network error');
        if (page == 1) {
          stopLoading(isConnected: false);
        } else {
          stopLoading();
          showNetworkError();
        }
      }
    }
  }

  void showGeneralError() {
    Fluttertoast.showToast(
        msg: "حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  void showServerError(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
  }

  void showNetworkError() {
    print("showNetworkError");
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(mcurrentContext!);
  }
}
