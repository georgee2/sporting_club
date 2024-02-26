import 'offer.dart';

class ServiceDetailsData {
  final Offer? service;

  ServiceDetailsData({this.service});

  factory ServiceDetailsData.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsData(
      service: json['service'] == null ? null : Offer.fromJson(json['service']),
    );
  }
}
