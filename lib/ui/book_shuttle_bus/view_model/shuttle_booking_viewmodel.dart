import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/my_shuttle_details_screen.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sporting_club/main.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';

import '../screens/online_shuttle_payment.dart';

class ShuttleBookingViewModel extends ChangeNotifier with BaseViewModel {
  ShuttleBusNetwork _busNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  BuildContext? mContext;

  ShuttleBookingViewModel(this._busNetwork, context) {
    mContext = context;
    print("init ShuttleViewModel");
  }

  ShuttleData shuttleData = ShuttleData();

  createPendingBooking({
    required String subType,
    required String memberIds,
    required String startDate,
    required String endDate,
    var totalPrice,
    required String totalDiscount,
    required String totalBeforeFees,
    required String favouriteLines,
    required String comment,
  }) async {
    print("init getShuttlePackages");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<OnlineBookingPayment> baseResponse =
          await _busNetwork.createPendingBooking(
        subType: subType,
        memberIds: memberIds,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice.toString(),
        totalDiscount: totalDiscount,
        totalBeforeFees: totalBeforeFees,
        favouriteLines: favouriteLines,
        comment: comment,
      );
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          if (baseResponse.data?.redirect_details ?? false) {
            global.navigatorKey.currentState?.pop();
            global.navigatorKey.currentState?.pop();
            global.navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (BuildContext context) => ShuttleDetailsScreen(
                      suttleId: baseResponse.data?.booking_id?.toString() ?? "",
                    )));
          } else {
            global.navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (BuildContext context) => OnlineShuttlePayment(
                      onlineBookingPayment: baseResponse.data,
                    )));
          }
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
            showAuthError();
          }
        } else if (baseResponse.statusCode == INVALIDTOKEN) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showAuthError();
          }
        } else if (baseResponse.statusCode == NO_NETWORK) {
          showNetworkError();
        } else {
          showGeneralError();
        }
        stopLoading();
      }
    } catch (error) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        print('ConnectivityResult mobile or wifi');
        showGeneralError();
      } else {
        print('network error');
        showNetworkError();
      }
      stopLoading();
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
    tokenUtilities.refreshToken(mContext!);
  }
}
