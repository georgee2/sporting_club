class OfflinePayment {
  String? schedual_paied_at;

  OfflinePayment({this.schedual_paied_at});

  factory OfflinePayment.fromJson(Map<String, dynamic> json) {
    return OfflinePayment(
      schedual_paied_at: json['schedual_paied_at'] == null ? null : json['schedual_paied_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "schedual_paied_at": this.schedual_paied_at,
    };
  }
}
