import 'package:sporting_club/data/model/offer.dart';
import 'ReponseListener.dart';

abstract class OfferServiceDetailsResponseListener extends ResponseListener {
  void setData(Offer? data);

  void showInterestedSuccessfully();
  void showImageNetworkError();
}
