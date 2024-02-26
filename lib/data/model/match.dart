class Match {
  final String? id;
  final String? home_team;
  final String? away_team;
  final String? home_logo;
  final String? away_logo;
  final String? home_points;
  final String? away_points;
  final String? location;
  final String? time;
  final String? category_title;
  final String? descriptions;
  String? url;

  Match({
    this.id,
    this.home_team,
    this.away_team,
    this.home_logo,
    this.away_logo,
    this.home_points,
    this.away_points,
    this.location,
    this.time,
    this.category_title,
    this.descriptions,
    this.url,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] == null ? null : json['id'],
      home_team: json['home_team'] == null ? null : json['home_team'],
      away_team: json['away_team'] == null ? null : json['away_team'],
      home_logo: json["home_logo"] == null ? null : json['home_logo'],
      away_logo: json["away_logo"] == null ? null : json['away_logo'],
      home_points: json['home_points'] == null ? null : json['home_points'],
      away_points: json['away_points'] == null ? null : json['away_points'],
      location: json["location"] == null ? null : json['location'],
      time: json["time"] == null ? null : json['time'],
      category_title:
          json["category_title"] == null ? null : json['category_title'],
      descriptions: json["descriptions"] == null ? null : json['descriptions'],
      url: json["url"] == null ? null : json['url'],
    );
  }
}
