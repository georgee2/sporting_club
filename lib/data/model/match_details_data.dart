import 'match.dart';

class MatchDetailsData {
  final Match? match;

  MatchDetailsData({this.match});

  factory MatchDetailsData.fromJson(Map<String, dynamic> json) {
    return MatchDetailsData(
      match: json['team'] == null ? null : Match.fromJson(json['team']),
    );
  }
}
