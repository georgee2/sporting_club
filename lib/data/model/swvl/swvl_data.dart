import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

class SwvlData{

  int currentOrNextRouteIndex;
  Set<RippleMarker> markers;
  Set<Polyline> polylines;
  Set<Circle> circles;
  String pickupPointAddress;

  SwvlData({
    this.currentOrNextRouteIndex = -1,
    required this.markers,
    required this.polylines,
    required this.circles,
    this.pickupPointAddress = ""
  });


}