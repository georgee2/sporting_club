import 'package:sporting_club/data/model/real_estate/time_slot.dart';
import 'package:sporting_club/data/model/real_estate/working_date.dart';

class RealEstateAvailableDatesData {
  final List<WorkingDate>? dates;

  RealEstateAvailableDatesData({
    this.dates,
  });

  factory RealEstateAvailableDatesData.fromJson(Map<String, dynamic> json) {
    List<WorkingDate> datesList = [];
    if (json['work_hours'] != null) {
      var list = json['work_hours'] as List;
      if (list != null) {
        datesList = list.map((i) => WorkingDate.fromJson(i)).toList();
      }
    }

    return RealEstateAvailableDatesData(
      dates: json['work_hours'] == null ? null : datesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "work_hours": this.dates,
    };
  }
}
