class UpcommingBooking {
  final String? id;
  final String? bookingCode;
  final String? bookingMemberName;
  final String? bookingDate;
  final String? bookingFrom;
  final String? subCategory;
  final String? parentCategory;
  final String? link;

  UpcommingBooking({
    this.id,
    this.bookingCode,
    this.bookingMemberName,
    this.bookingDate,
    this.bookingFrom,
    this.subCategory,
    this.parentCategory,
    this.link,
  });

  factory UpcommingBooking.fromJson(Map<String, dynamic> json) {
    return UpcommingBooking(
      id: json['id'] == null ? null : json['id'],
      bookingCode: json['booking_code'] == null ? null : json['booking_code'],
      bookingMemberName: json['booking_member_name'] == null ? null : json['booking_member_name'],
      parentCategory: json['parentCategory'] == null ? null : json['parentCategory'],
      subCategory: json['subCategory'] == null ? null : json['subCategory'],
      bookingDate: json['booking_date'] == null ? null : json['booking_date'],
      bookingFrom: json['booking_duration_from'] == null ? null : json['booking_duration_from'],
      link: json['link'] == null ? null : json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "booking_code": this.bookingCode,
      "booking_member_name": this.bookingMemberName,
      "parentCategory": this.parentCategory,
      "subCategory": this.subCategory,
      "booking_date": this.bookingDate,
      "booking_duration_from": this.bookingFrom,
    };
  }
}