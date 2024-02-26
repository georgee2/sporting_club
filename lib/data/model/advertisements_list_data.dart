import 'dart:convert';

import 'advertisement_data.dart';

class AdvertisementsListData {
  final List<AdvertisementData>? advertisement;

  AdvertisementsListData({
    this.advertisement,
  });

  factory AdvertisementsListData.fromJson(Map<String, dynamic> json) {
    List<AdvertisementData> adsList = [];
    if (json['advertisement'] != null) {
      var list = json['advertisement'] as List;
      if (list != null) {
        adsList = list.map((i) => AdvertisementData.fromJson(i)).toList();
      }
    }
    return AdvertisementsListData(
      advertisement: json['advertisement'] == null ? null : adsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "advertisement": jsonEncode(advertisement?.map((e) => e.toJson()).toList()),
    };
  }
}
