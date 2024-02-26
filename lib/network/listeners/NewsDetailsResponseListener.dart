import 'package:sporting_club/data/model/news.dart';
import 'ReponseListener.dart';

abstract class NewsDetailsResponseListener extends ResponseListener {
  void setNews(News? news);

  void showImageNetworkError();
}
