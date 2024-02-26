import 'package:sporting_club/data/model/trips/booking_request.dart';

class BookingRequestData {
  final BookingRequest? bookingRequest;

  BookingRequestData({
    this.bookingRequest,
  });

  factory BookingRequestData.fromJson(Map<String, dynamic> json) {
    return BookingRequestData(
      bookingRequest: json['bookingRequest'] == null
          ? null
          : BookingRequest.fromJson(json['bookingRequest']),
    );
  }
}
