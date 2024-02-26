import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/model/trips/trips_interests_data.dart';
import 'ReponseListener.dart';

abstract class TripsResponseListener extends ResponseListener{

  void setTrips(TripsData? tripsData);
  void setInterests(TripsInterestsData? tripsInterestsData);
  void showImageNetworkError();

}