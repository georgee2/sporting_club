import 'package:sporting_club/data/model/complaint.dart';
import 'ReponseListener.dart';

abstract class ComplaintDetailsResponseListener extends ResponseListener {
  void setComplaint(Complaint? complaint);

  void showImageNetworkError();
}
