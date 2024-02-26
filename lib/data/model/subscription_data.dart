class SubscriptionData {
  final String? playerId;

  SubscriptionData({this.playerId});

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      playerId: json['player_id'] == null ? null : json['player_id'],
    );
  }
}
