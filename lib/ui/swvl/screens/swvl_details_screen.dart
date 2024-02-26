import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/swvl/swvl_data.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/network/repositories/swvl_rides_network.dart';
import 'package:sporting_club/ui/swvl/helper/swvl_point_type.dart';
import 'package:sporting_club/ui/swvl/view_model/swvl_details_viewmodel.dart';
import 'package:sporting_club/utilities/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sporting_club/utilities/custom_map_markers_utils/custom_map_marker_builder.dart';
import 'package:sporting_club/utilities/map_utilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

class SwvlDetailsScreen extends StatefulWidget {
  String suttleId;
  Rides ride;

  SwvlDetailsScreen({required this.suttleId, required this.ride});

  @override
  State<StatefulWidget> createState() {
    return SwvlDetailsScreenScreenState();
  }
}

class SwvlDetailsScreenScreenState extends State<SwvlDetailsScreen> {
  // final pdf = pw.Document();
  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  SwvlData? swvlData;
  late List<MarkerData> _customMarkers;
  final locations = const [
    LatLng(37.42796133580664, -122.085749655962),
    LatLng(37.41796133580664, -122.085749655962),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      try {
        Provider.of<SwvlDetailsViewModel>(mProviderContext!, listen: false)
            .getSwvlRideDetails(ride :widget.ride);
      } catch (e) {
        print(e.toString());
      }
    });
    _customMarkers = [];
  }

  _customMarker(String status, String icon, String title, String snippt) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          margin: EdgeInsets.only(right: 50),
          decoration: BoxDecoration(color: AppColors.white,
          borderRadius: BorderRadius.circular(6)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    status+" ",
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.black,
                        fontWeight: FontWeight.normal),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                   snippt,
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ) ,
              Text(
                title,
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.green,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        Image.asset(icon, width: 20,height: 20,)

      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "تتبع رحلتك",
            ),
            leading: IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
          backgroundColor: Color(0xfff9f9f9),
          body:



          SlidingUpPanel(
            borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(20), topEnd: Radius.circular(20)),
            controller: panelController,
            panel: buildPanel(),
            body: buildBody(),
            maxHeight: 225,
            minHeight: 40,
          ),
        ),
      ),
    );
  }

  PanelController? panelController = new PanelController();

  GoogleMapController? _controller;
  final mapController = Completer<GoogleMapController>();

  buildBody() {
    return ChangeNotifierProvider<SwvlDetailsViewModel>(
      create: (context) => SwvlDetailsViewModel(SwvlRidesNetwork(), context),
      child: Selector<SwvlDetailsViewModel, SwvlData>(
        selector: (_, viewModel) => viewModel.swvlData,
        builder: (providerContext, viewModelShuttleData, child) {
          mProviderContext = providerContext;
          Set<RippleMarker> markers = viewModelShuttleData.markers;
          Set<Polyline> polylines = viewModelShuttleData.polylines;
          Set<Circle> circles = viewModelShuttleData.circles;
          if (markers.isNotEmpty) {
            _customMarkers.add(
              MarkerData(
                marker:RippleMarker(markerId:  markers.first.markerId, position:  markers.first.position),
                child: _customMarker( "البدء",
                    markers.first.markerId.value.split("_")[2]=="coming"?SwvlPointType.coming.icon:SwvlPointType.past.icon,
                    markers.first.infoWindow.title ?? "", markers.first.infoWindow.snippet ?? ""),
              ),
            );

            _customMarkers.add(
              MarkerData(
                marker:RippleMarker(markerId:  markers.last.markerId, position:  markers.last.position),
                child: _customMarker( "يصل",
                    markers.last.markerId.value.split("_")[2]=="coming"?SwvlPointType.coming.icon:SwvlPointType.past.icon,
                    markers.last.infoWindow.title ?? "", markers.last.infoWindow.snippet ?? ""),
              ),
            );
          }

          return
            ScreenHandler<SwvlDetailsViewModel>(
              child:

            Stack(
              children: [
                Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: CustomGoogleMapMarkerBuilder(
                    customMarkers: _customMarkers,
                    builder: (BuildContext context, Set<Marker>? newMarkers) {
                      Set<RippleMarker> mapMarkers=Set();
                      if(markers.isNotEmpty&&(newMarkers?.isNotEmpty??false)){
                        var firsRippleMarker = RippleMarker(
                            markerId: newMarkers?.first.markerId??markers.first.markerId,
                            position: newMarkers?.first.position??markers.first.position,
                          infoWindow: newMarkers?.first.infoWindow??markers.first.infoWindow,
                          icon: newMarkers?.first.icon??markers.first.icon,
                            ripple: markers.first.ripple,
                           );
                        mapMarkers.add(firsRippleMarker);
                        markers.forEach((element) {
                          if((element.markerId!=markers.first.markerId)&&(element.markerId!=markers.last.markerId)){
                            mapMarkers.add(element);
                          }
                        });
                        var lastRippleMarker = RippleMarker(
                          markerId: newMarkers?.last.markerId??markers.last.markerId,
                          position: newMarkers?.last.position??markers.last.position,
                          infoWindow: newMarkers?.last.infoWindow??markers.last.infoWindow,
                          icon: newMarkers?.last.icon??markers.last.icon,
                          ripple: markers.last.ripple,
                        );
                        mapMarkers.add(lastRippleMarker);
                        // mapMarkers.add(newMarkers?.last??markers.last);
                        if((markers.isNotEmpty || polylines.isNotEmpty)&& _controller != null){
                          _controller?.animateCamera(CameraUpdate.newLatLngBounds(
                              MapUtilities.getBounds(markers, polylines), 90
                          ));
                          // markIndex = (markers.length / 2).round();
                        }
                      }
                      return
                        Animarker(
                          curve: Curves.ease,
                          rippleRadius: 0.1,
                          useRotation: false,
                          duration: Duration(milliseconds: 1500),
                          mapId: mapController.future.then<int>((value) => value.mapId), //Grab Google Map Id
                          markers:mapMarkers,
                          rippleColor: Colors.teal, // Color of fade ripple circle
                          child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: markers.isNotEmpty
                                  ? markers.first.position
                                  : LatLng(
                                      widget.ride.stationsData?.first.loc
                                              ?.coordinates?[1] ??
                                          0,
                                      widget.ride.stationsData?.first.loc
                                              ?.coordinates?[0] ??
                                          0),
                              zoom: 13.7),
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          // markers: mapMarkers,
                          polylines: polylines,
                          circles: circles,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = controller;
                            _controller?.setMapStyle('[]');
                            mapController.complete(controller);

                          },
                        ),
                      );
                    }),
                ),

                Positioned(
                 top: 0,
                  right: 0,
                  child: Card(
                  margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
elevation: 3,
//                     decoration: BoxDecoration(
// color: AppColors.white
//                     ),
                    child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 8.0,
                                width: 8.0,
                                decoration: new BoxDecoration(
                                    color: AppColors.mediumGreen,
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                               "المحطات السابقة",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 8.0,
                                width: 8.0,
                                decoration: new BoxDecoration(
                                    color: AppColors.green,
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "المحطات القادمة",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),

                  ),
                ),
              ],
            )
          );
        },
      ),
    );
  }

  buildPanel() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 3,
              width: 50,
              color: Color(0xffEEEEEE),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    child: CachedNetworkImage(
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      imageUrl: widget.ride.captain?.picture ?? "",
                      placeholder: (context, url) =>
                          Image.asset("assets/placeholder.png"),
                      errorWidget: (context, o, t) =>
                          Image.asset("assets/placeholder.png"),
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.ride.captain?.name ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.green,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${widget.ride.busData?.make} - ${widget.ride.busData?.model}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        "${widget.ride.busData?.plates??""}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  launch("tel://${widget.ride.captain?.phone}");
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.phone,
                    color: AppColors.white,
                  ),
                  decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(25)),
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                height: 8.0,
                width: 8.0,
                decoration: new BoxDecoration(
                    color: AppColors.mediumGreen,
                    borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                widget.ride.stationsData?.first.name ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                height: 8.0,
                width: 8.0,
                decoration: new BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                widget.ride.stationsData?.last.name ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
