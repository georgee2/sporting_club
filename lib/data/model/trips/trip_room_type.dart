import 'available_room_views.dart';
import 'guest.dart';

class TripRoomType {
  int? id;
  String? name;
  int? capacity;
  List<AvailableRoomView>? available_room_views;
  AvailableRoomView? selectedRoomView;
  int? selectedCapacity;
  int?  guestCount;
  bool? isContainGuests;

  TripRoomType({
    this.id,
    this.name,
    this.capacity,
    this.available_room_views,
    this.selectedRoomView,
    this.selectedCapacity,
    this.guestCount=0,
    this.isContainGuests,
  });

  factory TripRoomType.fromJson(Map<String, dynamic> json) {
    List<AvailableRoomView> roomsList = [];
    if (json['available_room_views'] != null) {
      var list = json['available_room_views'] as List;
      if (list != null) {
        roomsList = list.map((i) => AvailableRoomView.fromJson(i)).toList();
      }
    }
    return TripRoomType(
      id: json['id'] == null ? null : json['id'],
      name: json['name'] == null ? null : json['name'],
      capacity: json['capacity'] == null ? null : json['capacity'],
      available_room_views:
          json['available_room_views'] == null ? null : roomsList,
    );
  }
}
