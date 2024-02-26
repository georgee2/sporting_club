import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/real_estate/booking.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_bookings_data.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/RealEstateBookingsResponseListener.dart';
import 'package:sporting_club/network/repositories/real_estate_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:sporting_club/widgets/real_estate/real_estate_reservation_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RealEstateReservationsScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return RealEstateReservationsScreenState();
  }
}

class RealEstateReservationsScreenState extends State<RealEstateReservationsScreen> implements NoNewrokDelagate,RealEstateBookingsResponseListener{

  bool _isLoading = false;
  bool _isNoNetwork = false;
  RealEstateNetwork _realEstateNetwork = RealEstateNetwork();
  List<Booking> _bookingsList = [];

  @override
  void initState() {
    super.initState();

    _realEstateNetwork.getRealEstateBookings(this);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('حُجزات الشهر العقاري'),
            ),
            body: _isNoNetwork ? _buildImageNetworkError() : ModalProgressHUD(
              child: _buildPageContent(),
              inAsyncCall: _isLoading,
              progressIndicator: CircularProgressIndicator(
                backgroundColor: Color.fromRGBO(0, 112, 26, 1),
                valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
              ),
            )
        )
    );
  }

  _buildPageContent(){
    return ListView.builder(
        itemCount: _bookingsList.length,
        itemBuilder: (_, int index) {
          return RealEstateReservationTile(
            booking:  _bookingsList[index],
          );
        }
    );
  }


  @override
  void reloadAction() {
    setState(() {
      _isNoNetwork = false;
      _realEstateNetwork.getRealEstateBookings(this);
    });
  }

  @override
  void setRealEstateBookings(RealEstateBookingsData? bookingsData) {
    setState(() {
      _bookingsList = bookingsData?.bookings??[];
    });
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void showGeneralError() {
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildImageNetworkError() {
    return NoNetwork(this);
  }
}