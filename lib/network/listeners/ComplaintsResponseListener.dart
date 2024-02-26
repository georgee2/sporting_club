import 'package:sporting_club/data/model/complaints_data.dart';
import 'ReponseListener.dart';

abstract class ComplaintsResponseListener extends ResponseListener {
  void setComplaints(ComplaintsData? complaintsData);
  void clearComplaints( );

  void showImageNetworkError();
}
