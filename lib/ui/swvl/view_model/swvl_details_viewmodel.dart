import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/base_view_model.dart';
import 'package:sporting_club/data/model/swvl/station_data.dart';
import 'package:sporting_club/data/model/swvl/swvl_data.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride_result.dart';
import 'package:sporting_club/data/response/base_response.dart';
import 'package:sporting_club/network/repositories/swvl_rides_network.dart';
import 'package:sporting_club/utilities/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:sporting_club/utilities/map_utilities.dart';
import 'package:sporting_club/utilities/token_utilities.dart';

import '../helper/swvl_point_type.dart';

class SwvlDetailsViewModel extends ChangeNotifier with BaseViewModel {
  SwvlRidesNetwork _swvlRidesNetwork;

  static int InvalidValues = 404;
  static int VALIDATION_ERROR = 422;
  static int UNAUTHORIZED = 403;
  static int INVALIDTOKEN = 400;
  static int NOT_ACCEPTABLE = 406;
  static int NO_NETWORK = 600;

  BuildContext? mcurrentContext;

  SwvlDetailsViewModel(this._swvlRidesNetwork,  currentContext) {
    mcurrentContext = currentContext;
    print("init TrafficLineViewModel");
  }


  Future<void> getSwvlRideDetails({required Rides ride}) async {
      startLoading();
    BaseResponse<Rides> baseResponse = await _swvlRidesNetwork.getSwvlRideDetails(rideId:ride.sId??"" );
    if (baseResponse.statusCode == 200) {
      if (baseResponse.data != null) {
        setUpDestinationPolyline(baseResponse.data??Rides());
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
          stopLoading();
          showNetworkError();
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




  SwvlData swvlData =
      SwvlData(circles: Set(), markers: Set(), polylines: Set());

  setUpDestinationPolyline(Rides rides) async {
    Set<RippleMarker> markers = await drawMarkers(rides);
int index =0;
    Set<Polyline> polylines = Set();
    Set<Circle> circles = Set();
    List<LatLng> points = [];
    List<LatLng> newPoints = [];
    StationsData? firstComingStationsData= rides.stationsData?.firstWhere((element) => element.status=="coming" , orElse: ()=>StationsData());
    rides.stationsData?.forEach((element) async {
      if( (element.sId == rides.stationsData?.first.sId ||
          element.sId == rides.stationsData?.last.sId)){
        circles.add(Circle(
          circleId: CircleId("${element.sId}big_circle"),
          center: LatLng(element.loc?.coordinates?[1] ?? 0,
              element.loc?.coordinates?[0] ?? 0),
          radius: (element.sId == rides.stationsData?.first.sId ||
              element.sId == rides.stationsData?.last.sId)
              ? 100
              : 70,
          strokeColor:
          (  (element.sId == rides.stationsData?.first.sId||element.sId == rides.stationsData?.last.sId)&& element.status=="coming" )
              ?AppColors.green.withOpacity(.3): AppColors.mediumGreen.withOpacity(.3)
          ,
          fillColor:
          (  (element.sId == rides.stationsData?.first.sId||element.sId == rides.stationsData?.last.sId)&& element.status=="coming" )
              ? AppColors.green.withOpacity(.3): AppColors.mediumGreen.withOpacity(.3),

          strokeWidth: (element.sId == rides.stationsData?.first.sId ||
              element.sId == rides.stationsData?.last.sId)
              ? 0
              : 0,

        ));
        circles.add(Circle(
          circleId: CircleId(element.sId ?? ""),
          center: LatLng(element.loc?.coordinates?[1] ?? 0,
              element.loc?.coordinates?[0] ?? 0),
          radius: (element.sId == rides.stationsData?.first.sId ||
              element.sId == rides.stationsData?.last.sId)
              ? 30
              : 40,
          strokeColor:
          (  (element.sId == rides.stationsData?.first.sId||element.sId == rides.stationsData?.last.sId)&& element.status=="coming" )
              ?AppColors.green: AppColors.mediumGreen
          ,
          fillColor:
          (  (element.sId == rides.stationsData?.first.sId||element.sId == rides.stationsData?.last.sId)&& element.status=="coming" )
              ? AppColors.green: AppColors.mediumGreen,

          strokeWidth: (element.sId == rides.stationsData?.first.sId ||
              element.sId == rides.stationsData?.last.sId)
              ? 2
              : 5,

        ));
      }
      points.add(LatLng(element.loc?.coordinates?[1] ?? 0,
          element.loc?.coordinates?[0] ?? 0));
      newPoints=[];
      if(index!=0){
        newPoints.insert(0, points[index-1]);
        newPoints.insert(1, points[index]);
        SwvlPointType swvlPointType=
            firstComingStationsData?.sId==element.sId?SwvlPointType.started:
        element.status=="coming"?SwvlPointType.coming:SwvlPointType.skipped;
        _addPolyLine(element ,index,  newPoints, swvlPointType);
      }
      index++;
    });
    polylines=Set<Polyline>.of(polylineMap.values);

    swvlData = SwvlData(
      circles:  circles,
      markers: markers,
      polylines: polylines,
    );
    notifyListeners();
  }
  Map<PolylineId, Polyline> polylineMap = {};
  _addPolyLine(StationsData element, index, newPoints , SwvlPointType swvlPointType) {
    Polyline linePolyline =Polyline(
      polylineId: PolylineId("${element.sId}"),
      width: 3,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      visible: true,
      color:swvlPointType.pointColor,
      points:newPoints,
    );
    polylineMap[ linePolyline.polylineId] = linePolyline;
  }

  Future<Set<RippleMarker>> drawMarkers(Rides rides) async {
    final BitmapDescriptor emptyPointIcon = await MapUtilities.createEmptyMarkerBitmap();
    final BitmapDescriptor pastStopPointIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.past.icon, 50);
    final BitmapDescriptor busStopPointIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.bus.icon, 50);
    final BitmapDescriptor startStopPointIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.started.icon, 50);
    final BitmapDescriptor endStopPointIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.ended.icon, 50);
    final BitmapDescriptor stoppingPointIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.coming.icon, 50);
    final BitmapDescriptor stoppingPointDimmedIcon =await MapUtilities.getBytesFromAsset(SwvlPointType.skipped.icon, 50);


    double startLat = rides.stationsData?.first.loc?.coordinates?[1] ?? 0;
    double startLongitude = rides.stationsData?.first.loc?.coordinates?[0] ?? 0;
    double endLat = rides.stationsData?.last.loc?.coordinates?[1] ?? 0;
    double endLongitude = rides.stationsData?.last.loc?.coordinates?[0] ?? 0;

    StationsData? comingStationsData=rides.stationsData?.firstWhere((element) => element.status==SwvlPointType.coming.title,  orElse: () => StationsData());
    StationsData? pastStationsData=rides.stationsData?.lastWhere((element) =>( element.status==SwvlPointType.past.title|| element.status==SwvlPointType.skipped.title),  orElse: () => StationsData());

    /////////////////
    RippleMarker? busLocationMarker;

    if(comingStationsData?.sId!=null&&pastStationsData?.sId!=null){

    double bus1Lat = comingStationsData?.loc?.coordinates?[1]??0;
    double bus1Longitude = comingStationsData?.loc?.coordinates?[0] ?? 0;

    double bus2Lat =  pastStationsData?.loc?.coordinates?[1]??0;
    double bus2Longitude = pastStationsData?.loc?.coordinates?[0] ?? 0;
    LatLng busLatLng= MapUtilities.getMidPoint(
      firstLat :bus1Lat,
      firstLng :bus1Longitude,
      secondLat :bus2Lat,
      secondLng :bus2Longitude,
      // secondArrivalTime :rides.stationsData?[3].estimatedAnalytics?.arrivalTime,
    );
    // LatLng((bus2Lat+bus1Lat)/2, (bus2Longitude+bus1Longitude)/2);
     busLocationMarker = RippleMarker(
        markerId: MarkerId('bus_location'),
        position: busLatLng,
        icon: busStopPointIcon,
        infoWindow: InfoWindow(
            title: "bus", ),
        ripple: false
    );
    }

    //////////////////////////

    Set<RippleMarker> markers = Set();

    rides.stationsData?.forEach((element) {
      var ripple= element.sId==comingStationsData?.sId;
      if (element.sId == rides.stationsData?.first.sId) {
        markers.add(RippleMarker(
            markerId: MarkerId('start_location_${element.status}'),
            position: LatLng(startLat, startLongitude),
            icon: startStopPointIcon,
            infoWindow: InfoWindow(
                title: element.name,
                snippet: "${element.estimatedAnalytics?.arrivalTime} - ${element.estimatedAnalytics?.departureTime}"
            ),
            ripple: rides.stationsData?.first.sId==comingStationsData?.sId
        ));
      } else if (element.sId == rides.stationsData?.last.sId) {
        markers.add(RippleMarker(
            markerId: MarkerId('destination_location_${element.status}'),
            position: LatLng(endLat, endLongitude),
            icon: endStopPointIcon,
            infoWindow: InfoWindow(
                title: element.name,
                snippet: "${element.estimatedAnalytics?.arrivalTime} - ${element.estimatedAnalytics?.departureTime}"

            ),
            ripple: rides.stationsData?.last.sId==comingStationsData?.sId
        ));
      } else {
        if(busLocationMarker!=null){
          markers.add(busLocationMarker);
        }
        markers.add(RippleMarker(
            markerId: MarkerId(element.sId ?? ""),
            position: LatLng(element.loc?.coordinates?[1] ?? 0,
                element.loc?.coordinates?[0] ?? 0),
            infoWindow: InfoWindow(
              title: element.name,
              snippet: "${element.estimatedAnalytics?.arrivalTime} - ${element.estimatedAnalytics?.departureTime}"
            ),
            visible: true,
            ripple:ripple,
            icon:
            element.status=="coming"? stoppingPointIcon:stoppingPointDimmedIcon,
        ));
      }
    });

    return markers;
  }

}
