import 'package:sporting_club/data/model/trips/offline_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';

import 'ReponseListener.dart';

abstract class PaymentTypeResponseListener extends ResponseListener {
  void showSuccessOffline(OfflinePayment? data);
  void showSuccessOnline(OnlinePayment? data);

}
