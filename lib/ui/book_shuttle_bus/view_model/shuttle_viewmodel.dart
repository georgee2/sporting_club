import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_price_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/traffic_line.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/shuttle_selection_summury_screen.dart';
import 'package:sporting_club/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/model/shuttle_bus/shuttle_traffic_response.dart';

class ShuttleViewModel extends ChangeNotifier with BaseViewModel {
  ShuttleBusNetwork _busNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  ShuttleViewModel(this._busNetwork, context) {
    mContext = context;
  }

  ShuttleData shuttleData = ShuttleData();
  BuildContext? mContext = global.navigatorKey.currentContext;

  getShuttlePackages() async {
    print("init getShuttlePackages");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttleData> baseResponse = (await Future.wait<dynamic>(
          [_busNetwork.getShuttlePackages(), getTrafficLineList()]))[0];
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          shuttleData = baseResponse.data ?? ShuttleData();
          availableMembersList = [];
          availableMembersList.addAll(
              shuttleData.memberList?.map((e) => e.memberId ?? "").toList() ??
                  []);
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

  Future<void> getTrafficLineList() async {
    // if (!isLoading) {
    //   startLoading();
    // }
    BaseResponse<ShuttleTrafficResponse> baseResponse =
        await _busNetwork.getTrafficList(null);

    if (baseResponse.statusCode == 200) {
      // page++;
      if (baseResponse.data != null) {
        // total = int.parse((baseResponse.data?.total?.isEmpty ?? true)
        //     ? "0"
        //     : (baseResponse.data?.total ?? "0"));
        trafficLineList = [...(baseResponse.data?.trafficLines ?? [])];
        noData = trafficLineList.isEmpty;
      }
      // stopLoading();
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
      } else {
        showGeneralError();
      }
      // if (page == 1) {
      // stopLoading(isConnected: false, noDataVal: true);
      // } else {
      //   stopLoading();
      //   showNetworkError();
      // }
    }
  }

  // List<String> selectedMembersList = [];
  Map<String, dynamic> selectedMembersList = {};

  List<String> availableMembersList = [];

  selectMembersList({Map<String, dynamic> selectedMember = const {}}) {
    calculatePriceForMembers(
      subscription: selectedShuttlePackageMap?.key ?? "",
      selectedMember: selectedMember,
    );
  }

  MapEntry<String, ShuttlePackage>? selectedShuttlePackageMap;

  selectShuttlePackages(
      {required MapEntry<String, ShuttlePackage> shuttlePackageMap}) {
    selectedShuttlePackageMap = shuttlePackageMap;
    // notifyListeners();
    checShuttleBooking(subscription: shuttlePackageMap.key);
  }

  ShuttleBookingData shuttleBookingData = ShuttleBookingData();

  checShuttleBooking({required String subscription}) async {
    print("init checShuttlekBooking");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttleBookingData> baseResponse =
          await _busNetwork.checShuttleBooking(subType: subscription);
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          shuttleBookingData = baseResponse.data ?? ShuttleBookingData();
          selectedMembersList = {};
          availableMembersList = [];
          availableMembersList.addAll(shuttleBookingData.memberList ?? []);
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
      }
      stopLoading();
      showNetworkError();
    }
  }

  List<int>? priceList = [];

  calculatePriceForMembers({
    required String subscription,
    Map<String, dynamic> selectedMember = const {},
  }) async {
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttlePriceData> baseResponse =
          await _busNetwork.calculatePriceForMembers(
        subType: subscription,
        totalMembers: selectedMember.keys.length.toString(),
        startDate: shuttleBookingData.startDate,
        endDate: shuttleBookingData.endDate,
      );
      if (baseResponse.statusCode == 200) {
        stopLoading();
        if (baseResponse.data != null) {
          print(baseResponse.data);
          for (int i = 0; i < selectedMember.length; i++) {
            selectedMembersList[selectedMember.keys.toList()[i]] =
                baseResponse.data?.priceList?[i] ?? 0;
          }
          notifyListeners();
          print(priceList);
        }
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

  calculatePrice(
      {required String subscription,
      required String totalMembers,
      required String comment,
      required String favouriteLines}) async {
    print("init checShuttlekBooking");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<ShuttleFees> baseResponse = await _busNetwork.calculatePrice(
        subType: subscription,
        totalMembers: totalMembers,
        startDate: shuttleBookingData.startDate,
        endDate: shuttleBookingData.endDate,
      );
      if (baseResponse.statusCode == 200) {
        stopLoading();
        if (baseResponse.data != null) {
          print(baseResponse.data);
          global.navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (BuildContext context) => ShuttleSelectionSummaryScreen(
                    subscription: subscription,
                    selectedMembersList: selectedMembersList.keys.toList(),
                    totalAmoutFees: baseResponse.data,
                    shuttleBookingData: shuttleBookingData,
                    comment: comment,
                    favouriteLines: favouriteLines,
                  )));
        }
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

  List<TrafficLine> trafficLineList = [];
  int bookingTotal = 0;

  // getTrafficLineList(int page) async {
  //   List<TrafficLine> trafficLines = [];
  //   trafficLines.add(
  //       TrafficLine(name: "خط شارع فؤاد", lineImage: "assets/fouad_line.png"));
  //   trafficLines.add(TrafficLine(
  //       name: "خط سموحه (كومباوند انطونيادس)",
  //       lineImage: "assets/smouha1_line.png"));
  //   trafficLines.add(TrafficLine(
  //       name: "خط سموحه (فيروزة سموحه)", lineImage: "assets/smouha2_line.png"));
  //   trafficLines.add(
  //       TrafficLine(name: "خط فلمنج", lineImage: "assets/flming_line.png"));
  //   trafficLines.add(
  //       TrafficLine(name: "خط جناكليس", lineImage: "assets/janaklis_line.png"));
  //   trafficLineList = trafficLines;
  //   notifyListeners();
  // }

  List<String> selectedtrafficLineList = [];

  selectTrafficLineList(TrafficLine trafficLine, bool add) async {
    List<String> selectedTrafficLines = [];
    selectedTrafficLines.addAll(selectedtrafficLineList);
    if (add) {
      selectedTrafficLines.add(trafficLine.id?.toString() ?? "");
    } else {
      selectedTrafficLines.remove(trafficLine.id?.toString() ?? "");
    }
    selectedtrafficLineList = selectedTrafficLines;
    notifyListeners();
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
