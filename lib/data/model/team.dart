import 'match.dart';

class Team {
  final List<Match>? matches;
  final String? name;

  Team({this.matches, this.name});

  factory Team.fromJson(Map<String, dynamic> json) {
    List<Match> matchesList = [];
    if (json['matchs'] != null) {
      var list = json['matchs'] as List;
      if (list != null) {
        matchesList = list.map((i) => Match.fromJson(i)).toList();
      }
    }

    return Team(
      matches: json['matchs'] == null ? null : matchesList,
      name: json['name'] == null ? null : json['name'],
    );
  }
}
