import 'emergency.dart';

class EmergencyData {
  final Emergency? emergency;

  EmergencyData({this.emergency});

  factory EmergencyData.fromJson(Map<String, dynamic> json) {
    return EmergencyData(
      emergency: json['emergency'] == null
          ? null
          : Emergency.fromJson(json['emergency']),
    );
  }
}
