import 'package:sporting_club/data/model/online_membership_payment.dart';
import 'package:sporting_club/data/model/trips/offline_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';

import 'ReponseListener.dart';

abstract class PaymentMembershipResponseListener extends ResponseListener {
  void showSuccessOnline(OnlineMembershipPayment? data);

}
