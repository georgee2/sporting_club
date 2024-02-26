import 'package:sporting_club/data/model/restaurant.dart';
import 'package:sporting_club/data/model/restaurants_data.dart';
import 'ReponseListener.dart';

abstract class RestaurantResponseListener extends ResponseListener {

  void setRestaurants(RestaurantsData? restaurantsData);

  void setRestaurantData(Restaurant? restaurant);

  void showImageNetworkError();
}
