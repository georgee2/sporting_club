import 'package:sporting_club/data/model/event.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'ReponseListener.dart';

abstract class SearchResponseListener extends ResponseListener {

  void setData(List<Offer>? data);

  void setEvents(List<Event>? events);

  void setTrips(TripsData? tripsData);

  void showImageNetworkError();
}
