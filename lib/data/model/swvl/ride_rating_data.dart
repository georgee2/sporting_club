
class RatingData {
  int? count;
  double? sum;

  RatingData({this.count, this.sum});

  RatingData.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['sum'] = this.sum;
    return data;
  }
}

class BusData {
  String? sId;
  String? make;
  String? model;
  int? seats;
  int? maxSeats;
  String? plates;

  BusData(
      {this.sId,
        this.make,
        this.model,
        this.seats,
        this.maxSeats,
        this.plates});

  BusData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    make = json['make'];
    model = json['model'];
    seats = json['seats'];
    maxSeats = json['max_seats'];
    plates = json['plates'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['make'] = this.make;
    data['model'] = this.model;
    data['seats'] = this.seats;
    data['max_seats'] = this.maxSeats;
    data['plates'] = this.plates;
    return data;
  }
}