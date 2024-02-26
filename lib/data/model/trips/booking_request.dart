class BookingRequest {
  final int? id;
  String? expired_at;
  final int? seats_count;
  final int? count;



  BookingRequest({
    this.id,
    this.expired_at,
    this.seats_count,
    this.count,

  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    print("here ");
    return BookingRequest(
      id: json['id'] == null ? null : json['id'],
      expired_at: json['expired_at'] == null ? null : json['expired_at'],
      seats_count: json['seats_count'] == null ? null : json['seats_count'],
      count: json['count'] == null ? null : json['count'],

    );
  }
}
