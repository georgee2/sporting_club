import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';

class ShuttlePriceData {
  List<dynamic>? priceList=[];

  ShuttlePriceData({ this.priceList, });

  ShuttlePriceData.fromJson(Map<String, dynamic> json) {

    if (json['data'] != null) {
      priceList = <dynamic>[];
      json['data'].forEach((value) {
        priceList?.add(value);
      });
    }
  }

}
