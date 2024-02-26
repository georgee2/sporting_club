import 'package:sporting_club/data/model/match.dart';
import 'ReponseListener.dart';

abstract class MatchDetailsResponseListener extends ResponseListener {
  void setMatch(Match? match);

  void showImageNetworkError();
}
