import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mapsToolkit;

class MapUtilities {
  static LatLngBounds getBounds(Set<Marker> markers, Set<Polyline> polylines) {
    List<LatLng> polylinesLatLngs = [];
    polylines.forEach((polyline) {
      polylinesLatLngs.addAll(polyline.points);
    });
    var lngs = markers.map<double>((m) => m.position.longitude).toList();
    polylinesLatLngs.forEach((latLng) {
      lngs.add(latLng.longitude);
    });
    var lats = markers.map<double>((m) => m.position.latitude).toList();
    polylinesLatLngs.forEach((latLng) {
      lats.add(latLng.latitude);
    });
    LatLngBounds bounds;
    if(lngs.isNotEmpty && lats.isNotEmpty){
      double topMost = lngs.reduce(max);
      double leftMost = lats.reduce(min);
      double rightMost = lats.reduce(max);
      double bottomMost = lngs.reduce(min);
      bounds = LatLngBounds(
        northeast: LatLng(rightMost, topMost),
        southwest: LatLng(leftMost, bottomMost),
      );

    } else {
      bounds = LatLngBounds(
        northeast: LatLng(0, 0),
        southwest: LatLng(0, 0),
      );
    }

    return bounds;
  }


  static Future<Uint8List> getBytesFromWidget(GlobalKey markerKey) async {
    RenderRepaintBoundary boundary =
    (markerKey.currentContext!.findRenderObject())! as RenderRepaintBoundary;
    var image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static List<LatLng> convertEncodedPolylineToPolyline(String encodedPolyline){
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> polylinePointsLatLng = polylinePoints.decodePolyline(encodedPolyline);
    List<LatLng> polylineLatLngs = [];
    polylinePointsLatLng.forEach((pointLatLng) {
      polylineLatLngs.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    });
    return polylineLatLngs;
  }
  static Future<BitmapDescriptor> createEmptyMarkerBitmap() async {
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);
    Picture p = recorder.endRecording();
    ByteData? pngBytes =
    await (await p.toImage(40, 40)).toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes!.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  static Future<BitmapDescriptor> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width , );
    ui.FrameInfo fi = await codec.getNextFrame();
    Uint8List? bitmapDescriptor = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    // return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(60, 60)), path);
    return BitmapDescriptor.fromBytes(bitmapDescriptor);

  }

  static LatLng getMidPoint({
    firstLat,
    firstLng,
    secondLat,
    secondLng,
    firstDeparturelTime,
    secondArrivalTime,
  }){
    final cityLondon = mapsToolkit.LatLng(firstLat, firstLng);
    final cityParis = mapsToolkit.LatLng(secondLat,secondLng);


    mapsToolkit.LatLng centerPoint = mapsToolkit.SphericalUtil.interpolate(cityLondon, cityParis, .5);

    return LatLng(centerPoint.latitude, centerPoint.longitude);
  }
}