import 'package:sporting_club/data/model/real_estate/upcomming_booking.dart';

class RealEstateUpcommingBookingData {
  final UpcommingBooking? booking;

  RealEstateUpcommingBookingData({
    this.booking,
  });

  factory RealEstateUpcommingBookingData.fromJson(Map<String, dynamic> json) {

    return RealEstateUpcommingBookingData(
      booking: json['booking'] == null ? null : UpcommingBooking.fromJson(json['booking']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "booking": this.booking,
    };
  }
}
