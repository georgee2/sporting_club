import 'event.dart';

class EventDetailsData {
  final Event? event;

  EventDetailsData({this.event});

  factory EventDetailsData.fromJson(Map<String, dynamic> json) {
    return EventDetailsData(
      event: json['event_single'] == null
          ? null
          : Event.fromJson(json['event_single']),
    );
  }
}
