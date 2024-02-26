


class SwvlRideLoc {
  String? type;
  List<double>? coordinates;

  SwvlRideLoc({this.type, this.coordinates});

  SwvlRideLoc.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}



