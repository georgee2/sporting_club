import 'package:sporting_club/data/model/activity_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'package:sporting_club/data/model/trips/trips_data_activity.dart';
import 'ReponseListener.dart';

abstract class ActivitiesResponseListener extends ResponseListener {
  void setData(ActivityData? categoriesData,List<Trip>? trip);

  void showImageNetworkError();
}
