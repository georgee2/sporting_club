import 'package:sporting_club/data/model/Payment.dart';

import 'Badge.dart';

class PaymentDetails {

  List<Payment>? items ;
  var  annual_subscription ;
  var total_after_fees ;
  List<Badge>?  unpaidCars ;
  bool? remaining;
//  "annual_subscription": 980,
//  "total_after_fees": 1002.344

  PaymentDetails({this.items,this.annual_subscription,this.total_after_fees,this.unpaidCars,this.remaining});
  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    List<Payment> items = [];
    if (json['items'] != null) {
      var list = json['items'] as List;
      if (list != null) {
        items = list.map((i) => Payment.fromJson(i)).toList();
      }
    }

    List<Badge> unpaidCars = [];
    if (json['unpaidCars'] != null) {
      var list = json['unpaidCars'] as List;
      if (list != null) {
        unpaidCars = list.map((i) => Badge.fromJson(i)).toList();
      }
    }

    return PaymentDetails(
        items: json["items"] == null ? null : items,
        annual_subscription: json['annual_subscription'] == null ? null : json['annual_subscription'],

        total_after_fees: json["total_after_fees"] == null ? null : json['total_after_fees'],
        unpaidCars: json["unpaidCars"] == null ? null : unpaidCars,
      remaining: json["remaining"] == null ? null : json['remaining'],

    );


  }
}
