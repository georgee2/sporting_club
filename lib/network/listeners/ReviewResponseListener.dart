import 'package:sporting_club/data/model/review_data.dart';
import 'ReponseListener.dart';

abstract class ReviewResponseListener extends ResponseListener{

  void setReview(ReviewData? reviewData);
  void showSuccess(ReviewData? reviewData);

}