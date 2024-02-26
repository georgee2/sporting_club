import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/contacting_info_data.dart';
import 'package:sporting_club/data/model/contacting_info.dart'
    as ContactingData;
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/ContactingInfoResponseListener.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/network/repositories/info_network.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CancellationPolicy extends StatefulWidget {
  int trip_id = 0;
  String data;

  CancellationPolicy(this.trip_id,this.data,
      );
  @override
  State<StatefulWidget> createState() {
    return CancellationPolicyState(this.trip_id,this.data,
    );
  }
}

class CancellationPolicyState extends State<CancellationPolicy>
    implements SeatsNumberResponseListener, NoNewrokDelagate {
  List<Marker> allMarkers = [];
  bool _isloading = false;
  bool _isNoNetwork = false;
  String data;

  BookingNetwork _bookingNetwork = BookingNetwork();
  int trip_id = 0;

  CancellationPolicyState(this.trip_id,this.data,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'شروط واحكام إلغاء الرحلات',
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          backgroundColor: Color(0xfff9f9f9),

          body: _buildContent(),
        ),
      ),
      inAsyncCall: _isloading,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }

  Widget _buildContent() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return (
         _isNoNetwork
            ? _buildImageNetworkError()
            :
         SingleChildScrollView(
        child: Column(
        children: <Widget>[
        Align(
          alignment: Alignment.centerRight,

          child:
                  Container(
                                  width: width ,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20,top: 20,bottom: 20),
                                    child: Align(
                                      child: Text(
                                       data
                                        ,

                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),
                                ),



),

            ]
                  )
         )

    );


  }

  Widget _buildCancelButton() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 25),
        child: Container(
          child: Center(
            child: Text(
               "الغاء الحجز"      ,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 20, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 8.0, // has the effect of softening the shadow
                spreadRadius: 0.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  0.0, // vertical, move down 10
                ),
              ),
            ],
            color:  Color(0xfff12b10) ,
          ),
          height: 50,
        ),
      ),
      onTap: ()  {
        _cancelAction();
      },
    );
  }
  Widget _buildSocialItem(String imageName, String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        imageName.contains('youtube')
            ? Image.asset(
                imageName,
                width: 23,
                height: 17,
                fit: BoxFit.fill,
              )
            : Image.asset(
                imageName,
              ),
        SizedBox(
          height: imageName.contains('youtube') ? 6 : 0,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color),
        )
      ],
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoNetwork(this),
    );
  }



  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isloading = true;
    });
  }

  @override
  void showGeneralError() {
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
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
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }



  void _cancelAction(){
    _bookingNetwork.cancelTrip(trip_id,this);

  }

  @override
  void reloadAction() {
  }

  @override
  void showSuccess(BookingRequest? bookingRequest) {
    // TODO: implement showSuccess
  }

  @override
  void showSuccessCancel() {
    Navigator.pop(context);
//    if(_reloadTripsDelagate != null){
//      _reloadTripsDelagate.reloadTripsAfterBooking();
//    }
    Fluttertoast.showToast(msg:'تم الغاء الاشتراك  بنجاح', toastLength: Toast.LENGTH_LONG);
    // TODO: implement showSuccessCancel
  }

  @override
  void showSuccessWaiting() {
    // TODO: implement showSuccessWaiting
  }

  @override
  void showSuccessCount(String? count) {
    // TODO: implement showSuccessCount
  }

  @override
  void showSuccessMemberName(String? memberName, String MemberId) {
    // TODO: implement showSuccessMemberName
  }
}
