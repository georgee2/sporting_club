import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/shuttle_bus/traffic_line.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/model/shuttle_bus/shuttle_traffic_response.dart';

class TrafficLineViewModel extends ChangeNotifier with BaseViewModel {
  ShuttleBusNetwork _busNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  BuildContext? mcurrentContext;

  TrafficLineViewModel(this._busNetwork, currentContext) {
    mcurrentContext = currentContext;
    print("init TrafficLineViewModel");
  }

  List<TrafficLine> trafficLineList = [];
  int total = 0;
  int page = 1;

  Future<void> getTrafficLineList({bool reset = false}) async {
    if (reset) {
      page = 1;
      trafficLineList.clear();
    }
    if (page > 1 && trafficLineList.length >= total) return;
    if (!isLoading) {
      startLoading();
    }

    // List<TrafficLine> trafficLines = [];
    // trafficLines.add(
    //     TrafficLine(name: "خط شارع فؤاد", lineImage: "assets/fouad_line.png"));
    // trafficLines.add(TrafficLine(
    //     name: "خط سموحه (كومباوند انطونيادس)",
    //     lineImage: "assets/smouha1_line.png"));
    // trafficLines.add(TrafficLine(
    //     name: "خط سموحه (فيروزة سموحه)", lineImage: "assets/smouha2_line.png"));
    // trafficLines.add(
    //     TrafficLine(name: "خط فلمنج", lineImage: "assets/flming_line.png"));
    // trafficLines.add(
    //     TrafficLine(name: "خط جناكليس", lineImage: "assets/janaklis_line.png"));
    // trafficLineList = trafficLines;
    BaseResponse<ShuttleTrafficResponse> baseResponse =
        await _busNetwork.getTrafficList(page);

    if (baseResponse.statusCode == 200) {
      page++;
      if (baseResponse.data != null) {
        total = baseResponse.data?.total ?? 0;
        trafficLineList = [
          ...trafficLineList,
          ...(baseResponse.data?.trafficLines ?? [])
        ];
        noData = trafficLineList.isEmpty;
      }
      stopLoading(noDataVal: noData);
    } else {
      if (baseResponse.statusCode == InvalidValues) {
        if (baseResponse.message != null) {
          showServerError(baseResponse.message ?? "");
          stopLoading();
        } else {
          showGeneralError();
          stopLoading();
        }
      } else if (baseResponse.statusCode == UNAUTHORIZED) {
        if (baseResponse.message != null) {
          showServerError(baseResponse.message ?? "");
          stopLoading();
        } else {
          showGeneralError();
          stopLoading();
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
        stopLoading();
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
