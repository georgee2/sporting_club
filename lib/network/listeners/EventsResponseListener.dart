import 'package:sporting_club/data/model/events_data.dart';
import 'ReponseListener.dart';

abstract class EventsResponseListener extends ResponseListener{

  void setEvents(EventsData? eventsData);
  void showImageNetworkError();

}