class Payment {

  final String? label;
  final String? count;
  final String? price_once;
  final String? total;
   bool? serv_Count;


  Payment({
    this.label,
    this.count,
    this.price_once,
    this.total,
    this.serv_Count,

  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      label: json['label'] == null ? null : json['label'],
      count: json['count'] == null ? null : json['count'],
      price_once: json['price_once'] == null ? null : json['price_once'],
      total: json["total"] == null ? null : json['total'],
      serv_Count: json["serv_Count"] == null ? null : json['serv_Count'],

    );
  }
}
