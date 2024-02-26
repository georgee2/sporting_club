import 'team.dart';

class TeamsData {
  final List<Team>? teams;
  final bool? has_interest;

  TeamsData({this.teams, this.has_interest});

  factory TeamsData.fromJson(Map<String, dynamic> json) {
    List<Team> teamsList = [];
    if (json['teams'] != null) {
      var list = json['teams'] as List;
      if (list != null) {
        teamsList = list.map((i) => Team.fromJson(i)).toList();
      }
    }

    return TeamsData(
      teams: json['teams'] == null ? null : teamsList,
      has_interest: json['has_interest'] == null ? false : json['has_interest'],
    );
  }
}
