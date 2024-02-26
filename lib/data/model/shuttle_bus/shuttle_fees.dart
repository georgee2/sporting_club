import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';

class ShuttleFees {
  // double? totalAmoutFees;
  var totalBeforeDiscount;
  var totalAfterDiscount;
  var amountDiscount;
  // var onlinePaymentAmount;
  ShuttleFees();

  ShuttleFees.fromJson(Map<String, dynamic> json) {
      totalBeforeDiscount = json['total_before_discount'];
      totalAfterDiscount = json['total_after_discount'];
      amountDiscount = json['amount_discount'];
    // totalAmoutFees = json['total_amout_with_fees'];

  }
  // {"total_before_discount":300,"total_after_discount":300,"amount_discount":0}

}
