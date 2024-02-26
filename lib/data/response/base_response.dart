import 'package:sporting_club/data/model/activity_data.dart';
import 'package:sporting_club/data/model/advertisements_list_data.dart';
import 'package:sporting_club/data/model/contacting_info_data.dart';
import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/emergency/emergency_category_data.dart';
import 'package:sporting_club/data/model/emergency_data.dart';
import 'package:sporting_club/data/model/event_details_data.dart';
import 'package:sporting_club/data/model/events_data.dart';
import 'package:sporting_club/data/model/fees.dart';
import 'package:sporting_club/data/model/images_list_data.dart';
import 'package:sporting_club/data/model/match_details_data.dart';
import 'package:sporting_club/data/model/news_search_data.dart';
import 'package:sporting_club/data/model/notifications_data.dart';
import 'package:sporting_club/data/model/online_membership_payment.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_dates.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_times_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_bookings_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_contracts_data.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking_data.dart';
import 'package:sporting_club/data/model/restaurants_data.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'package:sporting_club/data/model/service_details_data.dart';
import 'package:sporting_club/data/model/administratives_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/complaint_details_data.dart';
import 'package:sporting_club/data/model/complaints_data.dart';
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'package:sporting_club/data/model/news_details_data.dart';
import 'package:sporting_club/data/model/offer_details_data.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/review_data.dart';
import 'package:sporting_club/data/model/services_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_list_response.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_price_data.dart';
import 'package:sporting_club/data/model/subscription_data.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride_result.dart';
import 'package:sporting_club/data/model/teams_data.dart';
import 'package:sporting_club/data/model/trips/booking_request_data.dart';
import 'package:sporting_club/data/model/trips/follow_member.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/model/trips/trips_data_activity.dart';
import 'package:sporting_club/data/model/trips/trips_interests_data.dart';
import 'package:sporting_club/data/model/user_update_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

import '../model/notification.dart';
import '../model/shuttle_bus/shuttle_traffic_response.dart';

class BaseResponse<T> {
  final T? data;
  final String? error;
  final String? message;
  final int? statusCode;

  BaseResponse({this.data, this.error, this.message, this.statusCode});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    var _errorsList =
        json["errors"] == null ? null : json['errors'].values.toList();

    return BaseResponse(
      data: json["data"] == null ? null : dataFromJson(json),
      error: _errorsList != null ? _errorsList[0] : "",
      message: json["message"] == null ? null : json["message"],
      statusCode: json["code"] == null ? null : json["code"],
    );
  }

  static T? dataFromJson<T>(dynamic json) {
    if (T == LoginData) {
      return LoginData.fromJson(json['data']) as T;
    } else if (T == InterestsData) {
      return InterestsData.fromJson(json['data']) as T;
    } else if (T == CategoriesData) {
      return CategoriesData.fromJson(json['data']) as T;
    } else if (T == NewsData) {
      return NewsData.fromJson(json['data']) as T;
    } else if (T == NewsDetailsData) {
      return NewsDetailsData.fromJson(json['data']) as T;
    } else if (T == ReviewData) {
      return ReviewData.fromJson(json['data']) as T;
    } else if (T == AdministrativesData) {
      return AdministrativesData.fromJson(json['data']) as T;
    } else if (T == ComplaintsData) {
      return ComplaintsData.fromJson(json['data']) as T;
    } else if (T == ComplaintDetailsData) {
      return ComplaintDetailsData.fromJson(json['data']) as T;
    } else if (T == OffersData) {
      return OffersData.fromJson(json['data']) as T;
    } else if (T == OfferDetailsData) {
      return OfferDetailsData.fromJson(json['data']) as T;
    } else if (T == ServicesData) {
      return ServicesData.fromJson(json['data']) as T;
    } else if (T == ServiceDetailsData) {
      return ServiceDetailsData.fromJson(json['data']) as T;
    } else if (T == RestaurantsData) {
      return RestaurantsData.fromJson(json['data']) as T;
    } else if (T == EventsData) {
      return EventsData.fromJson(json['data']) as T;
    } else if (T == EventDetailsData) {
      return EventDetailsData.fromJson(json['data']) as T;
    } else if (T == NewsSearchData) {
      return NewsSearchData.fromJson(json['data']) as T;
    } else if (T == TeamsData) {
      return TeamsData.fromJson(json['data']) as T;
    } else if (T == MatchDetailsData) {
      return MatchDetailsData.fromJson(json['data']) as T;
    } else if (T == ContactingInfoData) {
      return ContactingInfoData.fromJson(json['data']) as T;
    } else if (T == EmergencyData) {
      return EmergencyData.fromJson(json['data']) as T;
    } else if (T == NotificationsData) {
      return NotificationsData.fromJson(json['data']) as T;
    } else if (T == SubscriptionData) {
      return SubscriptionData.fromJson(json['data']) as T;
    } else if (T == AdvertisementsListData) {
      return AdvertisementsListData.fromJson(json['data']) as T;
    } else if (T == TripsData) {
      return TripsData.fromJson(json['data']) as T;
    } else if (T == TripsInterestsData) {
      return TripsInterestsData.fromJson(json['data']) as T;
    } else if (T == TripDetailsData) {
      return TripDetailsData.fromJson(json['data']) as T;
    } else if (T == BookingRequestData) {
      return BookingRequestData.fromJson(json['data']) as T;
    }  else if (T == ServiceCategoriesData) {
      return ServiceCategoriesData.fromJson(json['data']) as T;
    } else if (T == ImagesListData) {
      return ImagesListData.fromJson(json['data']) as T;
    } else if (T == ActivityData) {
      return ActivityData.fromJson(json['data']) as T;
    }else if (T == TripsDataActivity) {
      return TripsDataActivity.fromJson(json['data']) as T;
    }else if (T == PaymentData) {
      return PaymentData.fromJson(json['data']) as T;
    } else if (T == UserUpdateData) {
      return UserUpdateData.fromJson(json['data']) as T;
    }else if (T == Fees) {
      return Fees.fromJson(json['data']) as T;
    } else if (T == OnlineMembershipPayment) {
      return OnlineMembershipPayment.fromJson(json['data']) as T;
    } else if (T == RealEstateContractsData) {
      return RealEstateContractsData.fromJson(json['data']) as T;
    } else if (T == RealEstateUpcommingBookingData) {
      return RealEstateUpcommingBookingData.fromJson(json['data']) as T;
    } else if (T == RealEstateAvailableTimesData) {
      return RealEstateAvailableTimesData.fromJson(json['data']) as T;
    } else if (T == RealEstateAvailableDatesData) {
      return RealEstateAvailableDatesData.fromJson(json['data']) as T;
    } else if (T == RealEstateBookingsData) {
      return RealEstateBookingsData.fromJson(json['data']) as T;
    } else if (T == FollowMembersData) {
      return FollowMembersData.fromJson(json) as T;
    }
    else if (T == ShuttleData) {
      return ShuttleData.fromJson(json['data']['data']) as T;
    }
    else if (T == ShuttleBookingData) {
      return ShuttleBookingData.fromJson(json['data']['data']) as T;
    }
    else if (T == ShuttleFees) {
      return ShuttleFees.fromJson(json['data']) as T;
    }
    else if (T == OnlineBookingPayment) {
      return OnlineBookingPayment.fromJson(json['data']) as T;
    }
    else if (T == ShuttleDetails) {
      return ShuttleDetails.fromJson(json['data']['data']) as T;
    }
    else if (T == ShuttleDetails) {
      return ShuttleDetails.fromJson(json['data']) as T;
    }
    else if (T == ShuttleList) {
      return ShuttleList.fromJson(json['data']) as T;
    }
    else if (T == ShuttleListResponse) {
      return ShuttleListResponse.fromJson(json['data']) as T;
    }
    else if (T == ShuttlePriceData) {
      return ShuttlePriceData.fromJson(json) as T;
    }else if(T ==ShuttleTrafficResponse){
      return ShuttleTrafficResponse.fromJson(json['data']) as T;
    }
    else if(T ==SwvlRideResult){
      return SwvlRideResult.fromJson(json['data']['data']) as T;
    }
    else if(T ==Rides){
      return Rides.fromJson(json['data']['data']) as T;
    }
    else if(T ==EmergencyCategoryData){
      return EmergencyCategoryData.fromJson(json['data']) as T;
    }
    else if(T ==NotificationModel){
      return NotificationModel.fromJson(json['data']) as T;
    }




    else {
      print('unknown class');
    }
  }
}
