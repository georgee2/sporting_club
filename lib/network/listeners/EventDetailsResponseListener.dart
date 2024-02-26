import 'package:sporting_club/data/model/event.dart';
import 'ReponseListener.dart';

abstract class EventDetailsResponseListener extends ResponseListener {
  void setEvent(Event? event);

  void showImageNetworkError();
}
