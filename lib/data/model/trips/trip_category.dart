class TripCategorey {
  int? id;
  String? name;
  final String? cancellation_policy;

  TripCategorey({this.id, this.name,this.cancellation_policy});

  factory TripCategorey.fromJson(Map<String, dynamic> json) {

    return TripCategorey(
        id: json['id'] == null ? null : json['id'],
        name: json['name'] == null ? null : json['name'],
        cancellation_policy: json['name'] == null ? null : json['cancellation_policy']
    );

  }

}
