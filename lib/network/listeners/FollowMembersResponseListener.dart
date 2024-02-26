import 'package:sporting_club/data/model/trips/follow_member.dart';
import 'package:sporting_club/data/model/trips/other_member.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'ReponseListener.dart';

abstract class FollowMembersResponseListener extends ResponseListener {
  void setFollowMembers(FollowMembersData? followMembers);
  void showSuccessMemberName(OtherMembers? memberName,  String MemberId);

}
