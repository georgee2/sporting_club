import 'event.dart';

class EventsData {
  final List<Event>? events;
final bool? has_interest;

  EventsData({this.events, this.has_interest});

  factory EventsData.fromJson(Map<String, dynamic> json) {
    List<Event> eventsList = [];
    if (json['events'] != null) {
      var list = json['events'] as List;
      if (list != null) {
        eventsList = list.map((i) => Event.fromJson(i)).toList();
      }
    }

    return EventsData(
      events: json['events'] == null ? null : eventsList,
      has_interest: json['has_interest'] == null ? false : json['has_interest'],
    );
  }
}
