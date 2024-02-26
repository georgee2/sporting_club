import 'package:sporting_club/data/model/real_estate/booking.dart';

class RealEstateBookingsData {
  final List<Booking>? bookings;

  RealEstateBookingsData({
    this.bookings,
  });

  factory RealEstateBookingsData.fromJson(Map<String, dynamic> json) {
    List<Booking> bookingsList = [];
    if (json['bookings'] != null) {
      var list = json['bookings'] as List;
      if (list != null) {
        bookingsList = list.map((i) => Booking.fromJson(i)).toList();
      }
    }

    return RealEstateBookingsData(
      bookings: json['bookings'] == null ? null : bookingsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "bookings": this.bookings,
    };
  }
}
