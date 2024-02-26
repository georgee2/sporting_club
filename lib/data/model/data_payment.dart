import 'package:sporting_club/data/model/PaymentDetails.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';

class PaymentData {
  final PaymentDetails? dataOPayment;
  final UserData? member;
   String? case_member;

  PaymentData({this.dataOPayment,this.member,this.case_member });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    PaymentDetails? dataOPayment ;
    UserData? member;
    if(json['dataOPayment'] != null){
      dataOPayment = PaymentDetails.fromJson(json['dataOPayment']);
    }
    if(json['member'] != null){
      member = UserData.fromJson(json['member']);
    }
    return PaymentData(
      dataOPayment: json['dataOPayment'] == null? null: dataOPayment,
member: json['member'] == null? null: member,
      case_member:json['case'] == null ? null : json['case'],

    );
  }
}
