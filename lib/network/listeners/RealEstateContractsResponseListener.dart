
import 'package:sporting_club/data/model/real_estate/real_estate_available_dates.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_times_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_contracts_data.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking_data.dart';
import 'package:sporting_club/network/listeners/ReponseListener.dart';

abstract class RealEstateContractsResponseListener extends ResponseListener {
  void setRealEstateContracts(RealEstateContractsData? contractsData);
  void setRealEstateAvailableHours(RealEstateAvailableTimesData? timesData);
  void setRealEstateAvailableDates(RealEstateAvailableDatesData? datesData);
  void setRealEstateUpcommingBooking(RealEstateUpcommingBookingData? bookingData,String? message);
  void realEstateBookedSuccessfully();
  void showImageNetworkError();
}
