
import 'package:sporting_club/data/model/real_estate/real_estate_bookings_data.dart';
import 'package:sporting_club/network/listeners/ReponseListener.dart';

abstract class RealEstateBookingsResponseListener extends ResponseListener {
  void setRealEstateBookings(RealEstateBookingsData? bookingsData);
  void showImageNetworkError();
}