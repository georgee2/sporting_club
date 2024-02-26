import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'ReponseListener.dart';

abstract class NewsResponseListener extends ResponseListener{

  void setCategories(CategoriesData? categoriesData);
  void setNews(NewsData? newsData);
  void showImageNetworkError();

}