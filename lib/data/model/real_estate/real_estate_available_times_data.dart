import 'package:sporting_club/data/model/real_estate/time_slot.dart';

class RealEstateAvailableTimesData {
  final List<TimeSlot>? slots;
  final int? capacity;

  RealEstateAvailableTimesData({
    this.slots,
    this.capacity,
  });

  factory RealEstateAvailableTimesData.fromJson(Map<String, dynamic> json) {
    List<TimeSlot> slotsList = [];
    if (json['slots'] != null) {
      var list = json['slots'] as List;
      if (list != null) {
        slotsList = list.map((i) => TimeSlot.fromJson(i)).toList();
      }
    }

    return RealEstateAvailableTimesData(
      slots: json['slots'] == null ? null : slotsList,
      capacity: json['capacity'] == null ? 0 : int.parse(json['capacity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "slots": this.slots,
      "capacity": this.capacity,
    };
  }
}
