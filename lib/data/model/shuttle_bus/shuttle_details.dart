import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';

class ShuttleDetails {
  String? date;
  String? price;
  String? shuttleId;
  String? bookingTransactionId;
  int? bookingMembersCount;
  List<ShuttleMember>? members;
  String? favouriteLines;
  String? comment;
  String? totalBeforeFees;
  double? totalAmoutFees;
  String? amountDiscount;

  ShuttleDetails(
      {this.date,
        this.price,
        this.shuttleId,
        this.bookingMembersCount,
        this.members,
        this.favouriteLines,
        this.comment,
        this.totalAmoutFees,
        this.amountDiscount,
      });
  ShuttleDetails.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    price = json['price'];
    shuttleId = json['id'];
    bookingTransactionId = json['booking_transaction_id'];
    bookingMembersCount = json['booking_members_count'];
    favouriteLines = json['favourite_lines'];
    comment = json['comment'];

    amountDiscount = json['total_discount']??"0";
    amountDiscount=(amountDiscount?.isEmpty??false)?"0":amountDiscount;

    totalBeforeFees = json['total_before_discount']??"0";
    totalBeforeFees=(totalBeforeFees?.isEmpty??false)?"0":totalBeforeFees;
    totalAmoutFees=(double.tryParse(price??"0")??0) ;


    if (json['members'] != null) {
      members = <ShuttleMember>[];
      json['members'].forEach((v) {
        members?.add(new ShuttleMember.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['price'] = this.price;
    data['id'] = this.shuttleId;
    data['booking_transaction_id'] = this.bookingTransactionId;
    data['booking_members_count'] = this.bookingMembersCount;
    if (this.members != null) {
      data['members'] = this.members?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}