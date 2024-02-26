
import 'bus_data.dart';
import 'captain_data.dart';
import 'station_data.dart';
import 'package:intl/intl.dart';

class Rides {
  String? sId;
  String? status;
  List<StationsData>? stationsData;
  Captain? captain;
  String? predictedStartDate;
  String? predictedEndDate;
  BusData? busData;

  String? startDay;
  String? startTime;
  String? endDay;
  String? endTime;
  Rides(
      {this.sId,
        this.status,
        this.stationsData,
        this.captain,
        this.predictedStartDate,
        this.predictedEndDate,
        this.busData});

  Rides.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    if (json['stations_data'] != null) {
      stationsData = <StationsData>[];
      json['stations_data'].forEach((v) {
        stationsData!.add(new StationsData.fromJson(v));
      });
    }
    captain =
    json['captain'] != null ? new Captain.fromJson(json['captain']) : null;
    predictedStartDate = json['predicted_start_date'];
    predictedEndDate = json['predicted_end_date'];
    busData = json['bus_data'] != null
        ? new BusData.fromJson(json['bus_data'])
        : null;


    DateTime parseStartDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parseUTC(predictedStartDate??"");
    DateTime parseEndDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parseUTC(predictedEndDate??"");
     startDay = DateFormat('EEEE', "ar").format(parseStartDate.toLocal(),);
     startTime = DateFormat('h:mm a',).format(parseStartDate.toLocal());

     endDay = DateFormat('EEEE', "ar").format(parseEndDate.toLocal(),);
     endTime = DateFormat('h:mm a',).format(parseEndDate.toLocal());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['status'] = this.status;
    if (this.stationsData != null) {
      data['stations_data'] =
          this.stationsData!.map((v) => v.toJson()).toList();
    }
    if (this.captain != null) {
      data['captain'] = this.captain!.toJson();
    }
    data['predicted_start_date'] = this.predictedStartDate;
    data['predicted_end_date'] = this.predictedEndDate;
    if (this.busData != null) {
      data['bus_data'] = this.busData!.toJson();
    }
    return data;
  }
}


class Loc {
  String? type;
  List<double>? coordinates;

  Loc({this.type, this.coordinates});

  Loc.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}



