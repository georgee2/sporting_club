class Fees {
   var total_amout_with_fees;

   Fees({
    this.total_amout_with_fees,

  });

  factory Fees.fromJson(Map<String, dynamic> json) {
    return Fees(
      total_amout_with_fees: json['total_amout_with_fees'] == null ? null : json['total_amout_with_fees'],

    );
  }

}
