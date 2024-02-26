
class TripsInterestsData {
  final List<String>? interestes;
  final bool? has_interests;

  TripsInterestsData({this.interestes, this.has_interests});

  factory TripsInterestsData.fromJson(Map<String, dynamic> json) {
    return TripsInterestsData(
      interestes: json['interestes'] == null
          ? null
          : List<String>.from(json['interestes']),
      has_interests:
          json['has_interests'] == null ? false : json['has_interests'],
    );
  }
}
