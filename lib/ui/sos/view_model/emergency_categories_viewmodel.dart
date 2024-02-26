import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/emergency/emergency_category.dart';
import 'package:sporting_club/data/model/emergency/emergency_category_data.dart';
import 'package:sporting_club/data/model/notification.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sporting_club/network/repositories/emergency_network.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../data/model/notifications_data.dart';
import '../../../utilities/location_manager.dart';
import 'package:location/location.dart';

class EmergencyCategoriesViewModel extends ChangeNotifier with BaseViewModel {
  EmergencyNetwork _emergencyNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  EmergencyCategoriesViewModel(this._emergencyNetwork, context) {
    mContext = context;
  }

  BuildContext? mContext = global.navigatorKey.currentContext;

  List<EmergencyCategory> sosCategoryList = [];
  LocationData? currentLocationData;

  // geolocator.Positioned?  currentLocationPositioned;
  getCurrentLocation() async {
    currentLocationData = await LocationManager.getCurrentLocation();
    // currentLocationPositioned=await LocationManager.determinePosition();
  }

  getEmergencyCategoryList() async {
    print("init getEmergencyCategoryList");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<EmergencyCategoryData> baseResponse =
          await _emergencyNetwork.getEmergencyCategoryList();
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          sosCategoryList = baseResponse.data?.emergencyCategoryList ?? [];
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
          showAuthError();
          // if (baseResponse.message != null) {
          //   showServerError(baseResponse.message ?? "");
          // } else {
          //   showGeneralError();
          // }
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

  NotificationModel sosNotification = NotificationModel();

  getEmergencyCategoryDetails(notification_id) async {
    print("init getEmergencyCategoryList");
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<NotificationsData> baseResponse =
          await _emergencyNetwork.getEmergencyCategoryDetails(notification_id);
      if (baseResponse.statusCode == 200) {
        if (baseResponse.data != null) {
          sosNotification =
              baseResponse.data?.notifications?[0] ?? NotificationModel();
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

  bool isSOSSent = false;
  EmergencyCategory selectedEmergencyCategory = EmergencyCategory();

  selectEmergencyCategory(EmergencyCategory emergencyCategory) {
    selectedEmergencyCategory = emergencyCategory;
    notifyListeners();
  }

  sendSOS(EmergencyCategory emergencyCategory) async {
    print("init sendSOS");
    if (!isLoading) {
      startLoading();
    }
    currentLocationData = await LocationManager.getCurrentLocation();
    if (currentLocationData != null) {
      isSOSSent = false;
      if (!isLoading) {
        startLoading();
      }
      try {
        BaseResponse<EmergencyCategoryData> baseResponse =
            await _emergencyNetwork.sendSOS(
          category: emergencyCategory.slug ?? "",
          location:
              "${currentLocationData?.latitude},${currentLocationData?.longitude}",
          sosName: LocalSettings.user?.user_name ?? "",
          sosPhone: LocalSettings.user?.phone ?? "",
        );
        if (baseResponse.statusCode == 200) {
          if (baseResponse.data != null) {
            isSOSSent = true;
            Fluttertoast.showToast(
                msg: "لقد تم ارسال الطلب", toastLength: Toast.LENGTH_LONG);
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
      }
    }
    stopLoading();
  }

  Future<void> acceptSos({
    required String uniqueId,
    required String sosId,
     String? emergencyCategoryId,
  }) async {
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<EmergencyCategoryData> baseResponse = await _emergencyNetwork.acceptSOS(uniqueId: uniqueId, sosId: sosId,);
      if (baseResponse.statusCode == 200) {
        showToastMessage("تم قبول الطلب");
        getEmergencyCategoryDetails(emergencyCategoryId);
      } else {
        if (baseResponse.statusCode == InvalidValues) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == UNAUTHORIZED) {
          showAuthError();
          // if (baseResponse.message != null) {
          //   showServerError(baseResponse.message ?? "");
          // } else {
          //   showGeneralError();
          // }
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

  Future<void> rejectSos({
    required String sosId,
    required String emergencyCategoryId,

  }) async {
    if (!isLoading) {
      startLoading();
    }
    try {
      BaseResponse<EmergencyCategoryData> baseResponse = await _emergencyNetwork.rejectSOS( sosId: sosId,);
      if (baseResponse.statusCode == 200) {
        showToastMessage("تم رفض الطلب");
        getEmergencyCategoryDetails(emergencyCategoryId);
      } else {
        if (baseResponse.statusCode == InvalidValues) {
          if (baseResponse.message != null) {
            showServerError(baseResponse.message ?? "");
          } else {
            showGeneralError();
          }
        } else if (baseResponse.statusCode == UNAUTHORIZED) {
          showAuthError();
          // if (baseResponse.message != null) {
          //   showServerError(baseResponse.message ?? "");
          // } else {
          //   showGeneralError();
          // }
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
