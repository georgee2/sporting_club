import 'dart:io';

import 'package:sporting_club/utilities/firebase_manager.dart';

class ApiUrls {
  /////// change google play json in android &ios

  // static final ENVIRONMENT = 'test';
  // static final ENVIRONMENT = 'live';

  // static final String MAIN_URL = "https://sporting-dev.objectsdev.com/new/wp-json/sporting-api/v1/"; // dev
  // static final String BOOKING_MAIN_URL = "https://sportingbooking-dev.objectsdev.com/api/v1/";
  // static final bool RELEASE_MODE = false;
  // static final String ONESIGNALKEY = "c37ed674-f612-49a8-a658-972e37c8dbaf";
  // static final String BOOKING_RECIEPT = "https://sportingbooking-dev.objectsdev.com";

  // //
  //
  // static final String MAIN_URL =
  //     "https://sportingtest4.objectsdev.com/wp-json/sporting-api/v1/"; // test
  // static final String BOOKING_MAIN_URL =
  //     "https://sportingbooking-test.objectsdev.com/api/v1/";
  // static final bool RELEASE_MODE = false;
  // static final String ONESIGNALKEY = "c37ed674-f612-49a8-a658-972e37c8dbaf";
  // static final String BOOKING_RECIEPT =
  //     "https://sportingbooking-test.objectsdev.com";

  // static final String MAIN_URL = "https://sporting-stage.objectsdev.com/new/wp-json/sporting-api/v1/";         // stage(client)
  //  static final String BOOKING_MAIN_URL = "https://sportingbooking.objectsdev.com/api/v1/";
  //  static final bool RELEASE_MODE = true;
  //  static final String ONESIGNALKEY = "c37ed674-f612-49a8-a658-972e37c8dbaf";
  // static final String BOOKING_RECIEPT = "https://sportingbooking.objectsdev.com";
  //

  //production
  static final String MAIN_URL =
      "https://www.alexsportingclub.com/new/wp-json/sporting-api/v1/"; // prod
  static final String BOOKING_MAIN_URL =
      "https://booking.alexsportingclub.com/api/v1/";
  static final bool RELEASE_MODE = true;
  static final String ONESIGNALKEY = "c2af908b-a933-479a-8a27-a5ec795a1ed6";
  static final String BOOKING_RECIEPT = "https://booking.alexsportingclub.com";


  static String FIREBASE_SENDER_ID = "";
  static String FIREBASE_API_KEY = "";
  static String FIREBASE_APP_ID = "";
  static String FIREBASE_PROJECT_ID = "";


  // static getFirebaseConfigurations() {
  //   if (ENVIRONMENT == 'test') {
  //     FIREBASE_SENDER_ID = "602628536236";
  //     FIREBASE_API_KEY = Platform.isAndroid
  //         ? "AIzaSyCAQTxTSzcMRVHlAHyJnIDwOYr1H5kZU4o"
  //         : "AIzaSyD2dwhL3DJFGghehQJS_CvpmgXplQsY0iU";
  //     FIREBASE_APP_ID = Platform.isAndroid
  //         ? "1:602628536236:android:0c420bfa3eb13f73aeec09"
  //         : "1:602628536236:ios:947d4b1f3a23a135aeec09";
  //     FIREBASE_PROJECT_ID = "sporting-club-ad328";
  //   } else if (ENVIRONMENT == 'live') {
  //     FIREBASE_SENDER_ID = "230676029629";
  //     FIREBASE_API_KEY = Platform.isAndroid
  //         ? "AIzaSyCC8Hq8owV9Pja9x4qn6_H7TntoAABZ_5U"
  //         : "AIzaSyBesRb6tFZ4qeXR-sMg-lKHsCEnpxlpzxY";
  //     FIREBASE_APP_ID = Platform.isAndroid
  //         ? "1:230676029629:android:b92590c087b99e5df657d4"
  //         : "1:230676029629:ios:6c125d31e0ac0575f657d4";
  //     FIREBASE_PROJECT_ID = "sporting-club-live";
  //   }
  // }

  static final String LOGIN = "user/request_code";
  static final String REQUIST_CODE_MESSAGE = "user/request_code_message";

  static final String REFRESH_TOKEN = "user/refresh_token";
  static final String VERIFY = "user/verify";
  static final String DOCTOR_LOGIN = "doctor/login";
  static final String GET_INTERESTS = "user/interests";
  static final String UPDATE_INTERESTS = "user/save_interests";
  static final String GET_PROFILE = "user/profile";
  static final String SUBSCRIBE_NOTIFICATIONS = "user/sub_notification";
  static final String UNSUBSCRIBE_NOTIFICATIONS = "user/unsub_notification";

  static final String NEWS_CATEGORIES = "news/categories";
  static final String NEWS = "news/list";
  static final String NEWS_INTERESTS = "news/interests";
  static final String NEWS_DETAILS = "news/single";

  static final String ADD_REVIEW = "user/add_review";
  static final String UPDATE_REVIEW = "user/update_review";
  static final String VIEW_REVIEW = "user/view_review";

  static final String ADD_EVENT_REVIEW = "events/add_review";
  static final String UPDATE_EVENT_REVIEW = "events/update_review";
  static final String VIEW_EVENT_REVIEW = "events/view_review";

  static final String GET_ADMINISTARTIVES = "complaint/administratives";
  static final String ADD_COMPLAINT = "complaint/add";
  static final String COMPLAINTS = "complaint/complaints";
  static final String VIEW_COMPLAINT = "complaint/view";
  static final String DISMISS_COMPLAINT = "complaint/dismiss";

  static final String OFFERS_CATEGORIES = "promotions/categories";
  static final String OFFERS = "promotions/list";
  static final String OFFER_DETAILS = "promotions/view";
  static final String OFFER_INTEREST = "promotions/interest";

  static final String SERVICES_CATEGORIES = "services/categories";
  static final String SERVICES = "services/list";
  static final String SERVICE_DETAILS = "services/view";
  static final String SERVICE_INTEREST = "services/interest";

  static final String SEARCH_OFFERS = "promotions/search";
  static final String SEARCH_SERVICES = "services/search";
  static final String SEARCH_EVENTS = "events/search";
  static final String SEARCH_NEWS = "news/search";

  static final String RESTAURANTS = "restaurants/list";
  static final String RESTAURANT_DETAILS = "restaurants/view";

  static final String EVENTS = "events/list";
  static final String EVENTS_INTERESTS = "events/interests";
  static final String EVENT_DETAILS = "events/single";
  static final String EVENT_REACT = "events/react";

  static final String MATCHES = "matchs/list";
  static final String MATCHES_INTERESTS = "matchs/interests";
  static final String MATCH_DETAILS = "matchs/single";

  static final String CONTACTING_INFO = "contact_info/details";
  static final String CONTACT_US = "contact_info/contact_us";
  static final String EMERGENCY = "contact_info/emergency";

  static final String NOTIFICATIONS = "notifications/list";
  static final String NOTIFICATIONS_READ = "notifications/read";
  static final String NOTIFICATIONS_STATUS = "notifications/change";
  static final String GET_INTERESTS_NOTIFICATION =
      "user/interests_notifications";
  static final String UPDATE_NOTIFICATIONS_STATUS =
      "user/save_interests_notifications";
  static final String NOTIFICATIONS_DELETE = "notifications/delete";
  static final String NOTIFICATIONS_DELETE_All = "notifications/delete_all";

  static final String ADVERTISEMENTS = "adver/list_ads";
  static final String TRIPS = "trips";
  static final String TRIPS_INTERESTS = "trips-interests";

  static final String BOOKING_REQUEST_CREATE = "bookings/requests/create";
  static final String BOOKING_WAITING_CREATE = "bookings/waiting/create";
  static final String GETAVALABLESEATS = "avaliable_seats";

  static final String BOOKING_CREATE = "bookings/create";
  static final String CHECK_NATIONAL_ID = "user/check_national_id";
  static final String UPDATE_PHONE = "user/update_phone";
  static final String HOME_Images = "home/images";

  static final String GET_Activites = "user/activity";
  static final String GET_BOOKING_TRIPS = "bookings";
  static final String Cancel_BOOKING_TRIPS = "cancel";
  static final String EXPIRE_BOOKING_TRIPS = "expire";
  static final String Request_BOOKING_TRIPS = "requests";
  static final String GET_MEMBER_NAME_BY_ID = "get_member_name";

  //onlinepayment
  static final String Payment_first_step = "user/online_payment_step_one";
  static final String Payment_Sec_step = "user/online_payment_step_two";
  static final String Caluculate_fees = "user/cal_total_with_fees";
  static final String Request_PAy = "user/xpay_iframe";

  // update user info
  static final String UPDATE_first_step = "user/check_memberid";
  static final String UPDATE_Sec_step = "user/check_step_two";
  static final String UPDATE_Third_step = "user/update_step_three";

  // followers
  static final String FOLLOW_MEMBERS = "followers";

  // real estate booking contracts
  static final String REAL_ESTATE_BOOKING_CONTRACTS =
      "real_estate_booking/contracts";
  static final String REAL_ESTATE_AVAILABLE_TIMES =
      "real_estate_booking/avaliable_times";
  static final String REAL_ESTATE_AVAILABLE_DATES =
      "real_estate_booking/avaliable_work_hours";
  static final String REAL_ESTATE_CREATE_BOOKING =
      "real_estate_booking/create_booking";
  static final String REAL_ESTATE_BOOKINGS = "real_estate_booking/bookings";
  static final String REAL_ESTATE_CHECK_UPCOMMING_BOOKING =
      "real_estate_booking/check_upcomming_booking";

// shuttle bus
  static final String SHUTTLE_BUS_DISPLAY_FORM = "shuttle_bus/display_form";
  static final String CHECK_SHUTTLE_BOOKING = "shuttle_bus/check_booking";
  static final String CALCULATE_PRICE_FIRST_SCREEN =
      "shuttle_bus/calculate_price_first_screen";
  static final String CALCULATE_PRICE = "shuttle_bus/calculate_price";
  static final String CREATE_PENDING_BOOKING =
      "shuttle_bus/create_pending_booking";
  static final String SHUTTLE_BOOKING_DETAILS = "shuttle_bus/booking_details";
  static final String SHUTTLE_BOOKING_LIST = "shuttle_bus/bookings_list";
  static final String SHUTTLE_TRAFFIC_LIST = "shuttle_bus/traffic_list";

  //swvl
  static final String SWVL_RIDE_LIST = "swvl/rides";
  static final String SWVL_RIDE_DETAILS = "swvl/ride_details";

  //
  static final String Doctor_Categories = "doctor/catogries";
  static final String SEND_SOS = "doctor/sos";
  static final String Doctor_Notification = "doctor/notification";
  static final String Doctor_ACCEPT_SOS = "doctor/accept";
  static final String Doctor_REJECT_SOS = "doctor/reject";
}
