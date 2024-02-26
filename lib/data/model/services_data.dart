import 'offer.dart';

class ServicesData {
  final List<Offer>? services;

  ServicesData({this.services});

  factory ServicesData.fromJson(Map<String, dynamic> json) {
    List<Offer> servicesList = [];
    if (json['services'] != null) {
      var list = json['services'] as List;
      if (list != null) {
        servicesList = list.map((i) => Offer.fromJson(i)).toList();
      }
    }

    return ServicesData(
      services: json['services'] == null ? null : servicesList,
    );
  }
}
