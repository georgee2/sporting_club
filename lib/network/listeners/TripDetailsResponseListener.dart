import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'ReponseListener.dart';

abstract class TripDetailsResponseListener extends ResponseListener {
  void setTrip(TripDetailsData? tripData);

  void showImageNetworkError();
}
