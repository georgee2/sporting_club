import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/offline_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';
import 'package:sporting_club/data/model/trips/other_member.dart';

class BookingBaseResponse<T> {
  final T? data;
  final String? error;
  final String? message;

  BookingBaseResponse({this.data, this.error, this.message});

  factory BookingBaseResponse.fromJson(Map<String, dynamic> json) {
//    var _errorsList =
//        json["errors"] == null ? null : json['errors'].values.toList();

    String? errorValue;
    for (final error in json.keys) {
      final value = json[error];
      if (error == "error") {
        if(value is String){
          errorValue = value;
          break;
        }
        for (var data in value.values) {
          errorValue = data;
          break;
        }
      }
      // prints entries like "AED,3.672940"
    }

    return BookingBaseResponse(
      data: json["data"] == null ? null : dataFromJson(json),
      error: errorValue != null ? errorValue : "",
      message: json["message"] == null ? null : json["message"],
    );
  }

  static T? dataFromJson<T>(dynamic json) {
    if (T == BookingRequest) {
      return BookingRequest.fromJson(json['data']) as T;
    }else  if (T == OfflinePayment) {
      return OfflinePayment.fromJson(json['data']) as T;
    }else  if (T == OnlinePayment) {
      return OnlinePayment.fromJson(json['data']) as T;
    }
    else  if (T == OtherMembers) {
      return OtherMembers.fromJson(json['data']) as T;
    }
    else  if (T == String) {
      return  json['data'] as T;
    }
    else {
      print('unknown class');
    }
  }
}
