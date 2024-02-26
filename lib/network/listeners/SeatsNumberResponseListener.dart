import 'package:sporting_club/data/model/trips/booking_request.dart';

import 'ReponseListener.dart';

abstract class SeatsNumberResponseListener extends ResponseListener {
  void showSuccess(BookingRequest? bookingRequest);
  void showSuccessWaiting();
  void showSuccessCancel();
  void showSuccessCount(String? count);
  void showSuccessMemberName(String? memberName,  String MemberId);

}
