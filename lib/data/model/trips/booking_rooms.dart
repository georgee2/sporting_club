class BookingRoom {
  int? room_type;
  int? room_view;
  int? capacity;
  int? guestsCount;
  bool? isContainGuests;

  BookingRoom({this.room_view, this.room_type, this.capacity,  this.guestsCount, this.isContainGuests});

  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      room_view: json['room_view'] == null ? null : json['room_view'],
      room_type: json['room_type'] == null ? null : json['room_type'],
      capacity: json['capacity'] == null ? null : json['capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "room_view": this.room_view,
      "room_type": this.room_type,
      "capacity": this.capacity,
      "guestsCount": this.guestsCount,
      "isContainGuests":this.isContainGuests,
    };
  }
}
