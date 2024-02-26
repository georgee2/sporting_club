class OnlineBookingPayment {

  String? iframe_url;
  int? booking_id;
  bool? redirect_details;


  OnlineBookingPayment({this.iframe_url,this.booking_id, this.redirect_details});

  factory OnlineBookingPayment.fromJson(Map<String, dynamic> json) {
    return OnlineBookingPayment(
      iframe_url: json['iframe_url'] == null ? null : json['iframe_url'],
      booking_id: json['booking_id'] == null ? null : json['booking_id'],
      redirect_details: json['redirect_details'] == null ? null : json['redirect_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iframe_url": this.iframe_url,
      "booking_id": this.booking_id,

    };
  }
}
