class Booking {
  final int? id;
  final String? parentCategory;
  final String? subCategory;
  final String? bookingDate;
  final String? bookingFrom;
  final String? bookingTo;

  Booking({
    this.id,
    this.parentCategory,
    this.subCategory,
    this.bookingDate,
    this.bookingFrom,
    this.bookingTo,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] == null ? null : json['id'],
      parentCategory: json['parentCategory'] == null ? null : json['parentCategory'],
      subCategory: json['subCategory'] == null ? null : json['subCategory'],
      bookingDate: json['bookingDate'] == null ? null : json['bookingDate'],
      bookingFrom: json['bookingFrom'] == null ? null : json['bookingFrom'],
      bookingTo: json['bookingTo'] == null ? null : json['bookingTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "parentCategory": this.parentCategory,
      "subCategory": this.subCategory,
      "bookingDate": this.bookingDate,
      "bookingFrom": this.bookingFrom,
      "bookingTo": this.bookingTo,
    };
  }
}