import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'ReponseListener.dart';

abstract class OffersServicesResponseListener extends ResponseListener {
  void setCategories(ServiceCategoriesData? categoriesData);
  void setOffersCategories(CategoriesData? categoriesData);

  void setData(List<Offer>? items);

  void showImageNetworkError();
}
