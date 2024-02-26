import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'ReponseListener.dart';

abstract class PaymentResponseListener extends ResponseListener{

  void showSuccess(PaymentData? data, {String? serverMessage});
  void showInvalidCode(String? data);

}