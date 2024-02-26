import 'package:sporting_club/data/model/teams_data.dart';
import 'ReponseListener.dart';

abstract class MatchesResponseListener extends ResponseListener{

  void setTeams(TeamsData? teamsData);
  void showImageNetworkError();

}