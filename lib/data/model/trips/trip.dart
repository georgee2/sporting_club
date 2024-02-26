import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/trips/seat_type.dart';
import 'package:sporting_club/data/model/trips/trip_category.dart';
import 'package:sporting_club/data/model/trips/trip_image.dart';
import 'package:sporting_club/data/model/trips/trip_price.dart';
import 'package:sporting_club/data/model/trips/trip_room_type.dart';

import 'available_room_views.dart';

class Trip {
  final int? id;
  final TripCategorey? category;
  final String? name;
  final String? start_date;
  final String? end_date;
   String? comment;

  final String? booking_start_date;
  final String? booking_end_date;
  final int? waiting_list_count;
  final int? available_seats;
  final int? seats_count;
  final String? accommodation_details;
  final String? optional_program_details;
  final String? visa_requirements;
  final int? visa_price;
  final TripImage? image;
  final List<TripPrice>? trip_prices;
  final List<TripRoomType>? formatted_room_types;
  final List<SeatType>? formatted_seat_types;
  final bool? accept_none_membership;
  final bool? accept_none_followers;
  var number_non_followers;
  final String? cancellation_policy;

  String? url;
  final double? min_deposite;
  final double? max_deposite;
   var limit_age;
  var max_age;

  var non_members;
  var number_guest;
  var children_chair_price;
  var bus_seat_age_limit ;
  var enable_bus_seat_age_limit ;
  int? trip_buses;
  Trip({
    this.id,
    this.name,
    this.start_date,
    this.end_date,
    this.booking_start_date,
    this.image,
    this.booking_end_date,
    this.category,
    this.url,
    this.accommodation_details,
    this.available_seats,
    this.optional_program_details,
    this.seats_count,
    this.visa_price,
    this.visa_requirements,
    this.waiting_list_count,
    this.trip_prices,
    this.formatted_room_types,
    this.formatted_seat_types,
    this.accept_none_membership,
    this.accept_none_followers,
    this.number_non_followers,
    this.cancellation_policy,
    this.min_deposite,
    this.max_deposite,
    this.limit_age,
    this.max_age,
    this.non_members,
    this.comment,
    this.number_guest,
    this.children_chair_price,
    this.bus_seat_age_limit = 0,
    this.enable_bus_seat_age_limit,
    this.trip_buses


  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<TripPrice> pricesList = [];
    if (json['trip_prices'] != null) {
      var list = json['trip_prices'] as List;
      if (list != null) {
        pricesList = list.map((i) => TripPrice.fromJson(i)).toList();
      }
    }
    List<TripRoomType> roomsList = [];
    if (json['formatted_room_types'] != null) {
      var list = json['formatted_room_types'] as List;
      if (list != null) {
        roomsList = list.map((i) => TripRoomType.fromJson(i)).toList();
      }
    }
    List<SeatType> seatsList = [];
    if (json['formatted_seat_types'] != null) {
      var list = json['formatted_seat_types'] as List;
      if (list != null) {
        seatsList = list.map((i) => SeatType.fromJson(i)).toList();
      }
    }
    return Trip(
      id: json['id'] == null ? null : json['id'],
      name: json['name'] == null ? null : json['name'],
      end_date: json['end_date'] == null ? null : json['end_date'],
      start_date: json["start_date"] == null ? null : json['start_date'],
      booking_start_date: json["booking_start_date"] == null
          ? null
          : json['booking_start_date'],
      image: json["image"] == null ? null : TripImage.fromJson(json['image']),
      booking_end_date:
          json["booking_end_date"] == null ? null : json['booking_end_date'],
      category: json["category"] == null ? null : TripCategorey.fromJson(json['category']),
      url: json["url"] == null ? null : json['url'],
      accommodation_details: json["accommodation_details"] == null
          ? null
          : json['accommodation_details'],
      available_seats:
          json["available_seats"] == null ? null : json['available_seats'],
      optional_program_details: json["optional_program_details"] == null
          ? null
          : json['optional_program_details'],
      seats_count: json["seats_count"] == null ? null : json['seats_count'],
      visa_price: json["visa_price"] == null ? null : json['visa_price'],
      visa_requirements:
          json["visa_requirements"] == null ? null : json['visa_requirements'],
      waiting_list_count: json["waiting_list_count"] == null
          ? null
          : json['waiting_list_count'],
      trip_prices: json['trip_prices'] == null ? null : pricesList,
      formatted_room_types:
          json['formatted_room_types'] == null ? null : roomsList,
      formatted_seat_types:
          json['formatted_seat_types'] == null ? null : seatsList,
      accept_none_membership: json["accept_none_membership"] == null
          ? false
          : json['accept_none_membership'],
      accept_none_followers: json["accept_none_followers"] == null
          ? false
          : json['accept_none_followers'],
      number_non_followers:  json["number_non_followers"] == null
          ? 0
          : json['number_non_followers'],
      cancellation_policy: json["terms_and_conditions"] == null
          ? null
          : json['terms_and_conditions'],
      max_deposite: json["max_deposite"] == null
          ? null
          : json['max_deposite'],
      min_deposite: json["min_deposite"] == null
          ? null
          : json['min_deposite'],
      limit_age: json["limit_age"] == null
          ? null
          : json['limit_age'],
      max_age: json["max_age"] == null
          ? null
          : json['max_age'],
      non_members:  json["non_members"] == null
          ? null
          : json['non_members'],
      number_guest:  json["number_guest"] == null
          ? 0
          : json['number_guest'],
      children_chair_price:   json["children_chair_price"] == null
          ? null
          : json['children_chair_price'],

      bus_seat_age_limit:  json["bus_seat_age_limit"] == null
          ? 0
          : json['bus_seat_age_limit'],
      enable_bus_seat_age_limit:  json["enable_bus_seat_age_limit"] == null
          ? null
          : json['enable_bus_seat_age_limit'],
      trip_buses:  json["trip_buses"] == null
          ? 0
          : json['trip_buses'],
    );
  }
}
