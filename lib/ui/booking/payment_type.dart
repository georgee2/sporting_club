import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sporting_club/data/model/trips/available_room_views.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/guest.dart';
import 'package:sporting_club/data/model/trips/offline_payment.dart';
import 'package:sporting_club/data/model/trips/online_payment.dart';
import 'package:sporting_club/data/model/trips/seat_type.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_room_type.dart';
import 'package:sporting_club/delegates/online_payment_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/delegates/success_payment_delegate.dart';
import 'package:sporting_club/network/listeners/PaymentTypeResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/ui/booking/send_invoice.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/ui/booking/online_web_payment.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/trips/cancellation_policy.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'online_web_payment.dart';

class PaymentType extends StatefulWidget {
  ///////

//this line commented   double childrenSeatsCost = 0.0;// _getChildrenSeatsCost();

  /////
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();

  List<TripRoomType> _selectedRoomsList = [TripRoomType()];
  List<SeatType> _selectedSeatsList = [];
  List<String> _selectedIDsList = [];
  List<String> nonFollowersIdsList = [];
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  String _email = "";
  String _phone1 = "";
  String _phone2 = "";
  String _phone3 = "";
  OnlinePaymentDelegate? _onlinePaymentDelegate;
  List<Guest> addedGuests;
  int childrenSeatsNumbers;

  PaymentType(
    this._trip,
    this._bookingRequest,
    this._selectedSeatsList,
    this._selectedRoomsList,
    this._selectedIDsList,
    this.nonFollowersIdsList,
    this.addedGuests,
    this.childrenSeatsNumbers,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
    this._email,
    this._phone1,
    this._phone2,
    this._phone3,
    this._onlinePaymentDelegate,
  );

  @override
  State<StatefulWidget> createState() {
    return PaymentTypeState(
      this._trip,
      this._bookingRequest,
      this._selectedSeatsList,
      this._selectedRoomsList,
      this._selectedIDsList,
      this.nonFollowersIdsList,
      this.addedGuests,
      this.childrenSeatsNumbers,
      this._reloadTripsDelagate,
      this._isFromPushNotification,
      this._email,
      this._onlinePaymentDelegate,
    );
  }
}

class PaymentTypeState extends State<PaymentType>
    implements
        PaymentTypeResponseListener,
        OnlinePaymentDelegate,
        SuccessPaymentDelegate {
  bool _isloading = false;
  List<TripRoomType> _selectedRoomsList = [TripRoomType()];
  List<SeatType> _selectedSeatsList = [];
  List<SeatType> _selectedChildrenSeatsList = [];
  List<String> _selectedIDsList = [];
  List<String> nonFollowersIdsList = [];

  bool _isFromPushNotification = false;
  String _email = "";
  ReloadTripsDelagate? _reloadTripsDelagate;
  double _totalCost = 0.0;

  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  OnlinePaymentDelegate? _onlinePaymentDelegate;
  List<Guest> addedGuests;
  int? childrenSeatsNumbers;
  bool isViewCancellationPolicy = false;

  PaymentTypeState(
    this._trip,
    this._bookingRequest,
    this._selectedSeatsList,
    this._selectedRoomsList,
    this._selectedIDsList,
    this.nonFollowersIdsList,
    this.addedGuests,
    this.childrenSeatsNumbers,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
    this._email,
    this._onlinePaymentDelegate,
  );

  BookingNetwork _bookingNetwork = BookingNetwork();

  bool _isSuccessOffline = false;
  bool _isSuccessOnline = false;

  String _paymentOfflineNote = "";
  Timer? timer;
  String _timerValue = "";

  String _ticketUrl = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (timer != null) {
      timer?.cancel();
    }
    _setTimer();

    return WillPopScope(
      onWillPop: () async {
        _isSuccessOffline || _isSuccessOnline
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
                (Route<dynamic> route) => false)
            : Navigator.of(context).pop(null);
        return true;
      },
      child: ModalProgressHUD(
        child: new Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  _trip.name ?? "",
                ),
                leading: IconButton(
                  icon: new Image.asset('assets/back_white.png'),
                  onPressed: () => _isSuccessOffline || _isSuccessOnline
                      ? Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Home()),
                          (Route<dynamic> route) => false)
                      : Navigator.of(context).pop(null),
                ),
              ),
              backgroundColor: Color(0xfff9f9f9),
              bottomNavigationBar: _buildFooter(),
              body: Stack(children: <Widget>[
                _buildContent(),
                isViewCancellationPolicy
                    ? _buildBottomCancellationPolicy()
                    : SizedBox(),
              ]),
            )),
        inAsyncCall: _isloading,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Color.fromRGBO(0, 112, 26, 1),
          valueColor:
              AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
        ),
      ),
    );
  }

  Widget _buildContent() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ListView(
      children: <Widget>[
        _buildHeader(),
        Container(
          color: Color(0xffeeeeee),
          height: 1,
        ),
        Container(
          padding: EdgeInsets.only(right: 20, top: 20),
          height: 60,
          child: Align(
              child: Text(
                'توقيت الرحلة',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        _buildTripDates(),
        Container(
          padding: EdgeInsets.only(right: 20, top: 20),
          height: 60,
          child: Align(
              child: Text(
                'بيانات الحجز',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        _buildBookingDetails(),
        Container(
          padding: EdgeInsets.only(right: 20, top: 20),
          height: 60,
          child: Align(
              child: Text(
                'إجمالي التكلفة',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        _buildCostDetails(),
        SizedBox(
          height: 25,
        ),
        ((_trip.max_deposite == null && _trip.min_deposite == null))
            ? SizedBox()
            : Container(
                color: Color(0xffeeeeee),
                margin: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: <Widget>[
                    (_trip.max_deposite == null && _trip.min_deposite == null)
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  'يمكن دفع مقدم حجز!',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Checkbox(
                                    value: _isEarlyPayment,
                                    onChanged: (val) {
                                      setState(() {
                                        _isEarlyPayment = !_isEarlyPayment;
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "دفع مقدم حجز",
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                    ((_trip.max_deposite == null &&
                                _trip.min_deposite == null) ||
                            !_isEarlyPayment)
                        ? SizedBox()
                        : Divider(),
                    ((_trip.max_deposite == null &&
                                _trip.min_deposite == null) ||
                            !_isEarlyPayment)
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Expanded(child: _buildEarlyPaymentField()),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  children: <Widget>[
                                    _trip.min_deposite == null
                                        ? SizedBox()
                                        : Text(
                                            "الحد الادنى ${Validation.replaceArabicNumber(_trip.min_deposite.toString())} ج ",
                                            style: TextStyle(
                                                color: Color(0xff646464),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700),
                                          ),
                                    _trip.max_deposite == null
                                        ? SizedBox()
                                        : Text(
                                            "الحد الاقصى ${Validation.replaceArabicNumber(_trip.max_deposite.toString())} ج ",
                                            style: TextStyle(
                                                color: Color(0xff646464),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
        SizedBox(
          height: 10,
        ),
        _buildTerms(),
        // Padding(
        //   padding: EdgeInsets.only(right: 20, top: 10),
        //   child: Align(
        //       child: Text(
        //         "في حالة الدفع اونلاين تكلفة الرحلة غير متضمنه مصاريف التحويل البنكي",
        //         style: TextStyle(
        //           color: Color(0xff03240a),
        //           fontSize: 14,
        //         ),
        //       ),
        //       alignment: Alignment.centerRight),
        // ),
        // _isSuccessOffline || _isSuccessOnline
        //     ? SizedBox()
        //     : Padding(
        //         padding:
        //             EdgeInsets.only(right: 20, top: 10, left: 20, bottom: 5),
        //         child: Align(
        //             child: Text(
        //               "سيتم اضافة ٢% رسوم في حالة الدفع الإلكتروني",
        //               style: TextStyle(
        //                 color: Color(0xff03240a),
        //                 fontSize: 14,
        //               ),
        //             ),
        //             alignment: Alignment.centerRight),
        //       ),
        SizedBox(
          height: 10,
        ),
        !_isSuccessOnline
            ? _isSuccessOffline
                ? SizedBox()
                : _buildOnlinePaymentButton()
            : _buildBackToTripsButton(),
        SizedBox(
          height: 10,
        ),
        // !_isSuccessOnline ? _buildOfflinePaymentButton() : SizedBox(),
        SizedBox(
          height: _isSuccessOffline ? 20 : 0,
        ),
        _isSuccessOffline
            ? Container(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Text(
                    'برجاء الدفع وتأكيد الحجز بمقر لجنة الرحلات بالنادي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff03240a),
                      fontSize: 15,
                    ),
                  ),
                ),
                width: width - 40,
              )
            : SizedBox(),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  // PanelController controller=PanelController;
  Widget _buildBottomCancellationPolicy() {
    // isViewCancellationPolicy = false;
    return SlidingUpPanel(
        minHeight: 200,
        panel:
            //  SingleChildScrollView(

            //  child:
            Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        child: new Text(
                          // "nnfjj hfshjhjfhj hjfhjhjf hjfh jhjfhjhj fhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhj nnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhjnnfjj hfshjhjfhj hjfhjhjf hjfhjhjfhjhjfhjhjfhjhjfghj hhfghhjfgjhhjfg hhhjhjgf hjhgfhhhfghjhjfgh gfhj"
                          Validation.replaceArabicNumber(
                              _trip.cancellation_policy ?? ""),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        alignment: Alignment.topRight,
                      )
                    ]),
              ),
              Align(
                child: GestureDetector(
                    child: Image.asset(
                      'assets/close_green_ic.png',
                      width: 30,
                      fit: BoxFit.fitWidth,
                    ),
                    onTap: () {
                      setState(() {
                        isViewCancellationPolicy = false;
                      });
                    }),
                alignment: Alignment.topLeft,
              ),
            ],
          ),
        )
        // )
        );
  }

  bool _isEarlyPayment = false;
  var _earlyPaymentController = TextEditingController();

  Widget _buildEarlyPaymentField() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _earlyPaymentController,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: '0',
                  ),
                  keyboardType: TextInputType.number,
                  keyboardAppearance: Brightness.light,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  'جنيه',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff03240a),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 8.0,
                // has the effect of softening the shadow
                spreadRadius: 5.0,
                // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  0.0, // vertical, move down 10
                ),
              ),
            ],
            color: Colors.white,
          ),
          height: 50,
          margin: EdgeInsets.only(bottom: 5, top: 10),
          padding: EdgeInsets.all(1),
        ),
      ),
    );
  }

  bool _isTermsAccepted = false;

  Widget _buildTerms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 20, left: 0, top: 10, bottom: 5),
            child: GestureDetector(
              child: _isTermsAccepted
                  ? Icon(
                      Icons.check_box,
                      color: Color(0xffff5c46),
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      color: Color(0xffbfbfbf),
                    ),
              onTap: () {
                setState(() {
                  //   _isTermsAccepted? isViewCancellationPolicy = true;
                  //  showSlideupView(context);
                  _isTermsAccepted = !_isTermsAccepted;
                  isViewCancellationPolicy = _isTermsAccepted;
                });
              },
            ),
          ),
          alignment: Alignment.centerRight,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 10, left: 0, top: 10, bottom: 5),
            child: Text(
              "أوافق على الشروط والأحكام الخاصة ب",
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
          alignment: Alignment.centerRight,
        ),
        GestureDetector(
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(right: 0, left: 5, top: 10, bottom: 5),
              child: Text(
                "سياسة اﻹلغاء",
                style: TextStyle(color: Color(0xff43a047), fontSize: 12),
              ),
            ),
            alignment: Alignment.centerRight,
          ),
          onTap: () => _cancellationPolicyAction(),
        ),
      ],
    );
  }

  void _cancellationPolicyAction() async {
    print("tripData.trip.cancellation_policy ${_trip.cancellation_policy}");
    if (_trip.cancellation_policy != null) {
//      if (await UrlLauncher.canLaunch(_tripData.cancellation_policy_url)) {
//        await UrlLauncher.launch(_tripData.cancellation_policy_url);
//      } else {
//        print("can't launch");
//      }
//    }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CancellationPolicy(
                _trip.id ?? 0,
                Validation.replaceArabicNumber(
                    _trip.cancellation_policy ?? "")),
          ));
    }
  }

  Widget _buildHeader() {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 150;

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Image.asset(
          'assets/header_step3.png',
          height: 70,
          fit: BoxFit.fitHeight,
        ),
      ),
      color: Colors.white,
//      height: 120,
    );
  }

  Widget _buildFooter() {
    int difference = 0;
    if (_bookingRequest.expired_at != null) {
//      final endTime = DateTime.parse(_bookingRequest.expired_at);
      final endTime = DateTime.parse("2019-10-24T12:48:23+02:00");
      final date2 = DateTime.now();
      if (endTime.isAfter(date2)) {
        difference = endTime.difference(date2).inSeconds;
        print("difference: " + difference.toString());
      } else {
        print('before');
      }
    }
    int estimateTs = DateTime.parse("2019-10-24T13:04:23+02:00")
        .millisecondsSinceEpoch; // set needed date

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          right: 20,
          left: 20,
        ),
        child: _isSuccessOnline
            ? _buildTicketButton()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _isSuccessOffline
                      ? _buildConfirmationMessage()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'سيتم الغاء الحجز تلقائياً بعد',
                              style: TextStyle(
                                color: Color(0xff03240a),
                                fontSize: 14,
                              ),
                            ),

//                      CountDownTimer(
//                        secondsRemaining: difference,
//                        countDownTimerStyle: TextStyle(
//                            color: Color(0xff03240a),
//                            fontSize: 14,
//                            fontWeight: FontWeight.w700),
//                        whenTimeExpires: () {
//                          setState(() {
//                            print('time endddddddd');
//                            if (!_isSuccessOffline) {
//                              Navigator.of(context).push(PageRouteBuilder(
//                                  opaque: false,
//                                  pageBuilder: (BuildContext context, _, __) =>
//                                      SessionExpired()));
//                            }
//                          });
//                        },
//                      ),
//                      StreamBuilder(
//                          stream:
//                              Stream.periodic(Duration(seconds: 1), (i) => i),
//                          builder: (BuildContext context,
//                              AsyncSnapshot<int> snapshot) {
//                            intl.DateFormat format = intl.DateFormat("hh:mm:ss");
//                            int now = DateTime.now().millisecondsSinceEpoch;
//                            Duration remaining =
//                                Duration(milliseconds: estimateTs - now);
//                            var dateString =
//                                '${format.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
//                            print(dateString);
//                            return Container(
//                              color: Colors.greenAccent.withOpacity(0.3),
//                              alignment: Alignment.center,
//                              child: Text(dateString),
//                            );
//                          }),
                            Text(
                              _timerValue,
                              style: TextStyle(
                                  color: Color(0xff03240a),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ],
              ),
      ),
      height: 80,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffeeeeee))),
        color: Colors.white,
      ),
    );
  }

  Widget _buildTripDates() {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 10),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'تاريخ الحجز',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                _trip.booking_start_date ?? "",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'تاريخ الرحلة',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20, left: 10, top: 10, bottom: 5),
                        child: Text(
                          "من",
                          style: TextStyle(
                            color: Color(0xff00701a),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    Align(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20, left: 10, top: 0, bottom: 0),
                        child: Text(
                          _trip.start_date ?? "",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    )
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20, left: 10, top: 10, bottom: 5),
                        child: Text(
                          "إلى",
                          style: TextStyle(
                            color: Color(0xff00701a),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    Align(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20, left: 10, top: 0, bottom: 0),
                        child: Text(
                          _trip.end_date ?? "",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
//        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 5.0,
              // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 10),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'اسم العضو',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                LocalSettings.user?.user_name ?? "",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'رقم العضوية',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                _getMembersIDs(),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            nonFollowersIdsList.isEmpty
                ? SizedBox()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20, top: 15),
                        child: Text(
                          'رقم العضوية لغير الاعضاء',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff43a047)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20, bottom: 15),
                        child: Text(
                          _getNonMembersIDs(),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Container(
                        color: Color(0xffeeeeee),
                        height: 1,
                      ),
                    ],
                  ),
        _trip.trip_buses==0?   SizedBox(): Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'عدد المقاعد المحجوزة',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            _trip.trip_buses==0?   SizedBox(): SizedBox(
              height: 5,
            ),
            _trip.trip_buses==0?   SizedBox():   Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                _bookingRequest.seats_count != null
                    ? _bookingRequest.seats_count.toString()
                    : "",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            _trip.trip_buses==0?   SizedBox(): Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'عدد الغرف المحجوزة',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                _selectedRoomsList.length.toString(),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
//        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 5.0,
              // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCostDetails() {
    double roomsCost = _getRoomsCost();
    double guestRoomsCost = _getGuestRoomsCost();

    double seatsCost = _getSeatsCost();
    num childrenSeatsCost = ((childrenSeatsNumbers ?? 0) > 0.0)
        ? ((childrenSeatsNumbers ?? 0) * (_trip.children_chair_price ?? 0))
        : 0.0; // _getChildrenSeatsCost();

    _totalCost = roomsCost + seatsCost + childrenSeatsCost+guestRoomsCost;
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 10),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'تكلفة العدد (بالغ)',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                Validation.replaceArabicNumber(roomsCost.toString()) +
                    "  جنيه مصري",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'تكلفة الضيوف',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, bottom: 15),
              child: Text(
                Validation.replaceArabicNumber(guestRoomsCost.toString()) +
                    "  جنيه مصري",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),


            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
            seatsCost != 0.0
                ? Padding(
                    padding: EdgeInsets.only(right: 20, top: 15),
                    child: Text(
                      'تكلفة سراير الاطفال',
                      style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
                    ),
                  )
                : SizedBox(),
            seatsCost != 0.0
                ? Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 15),
                    child: Text(
                      Validation.replaceArabicNumber(seatsCost.toString()) +
                          "  جنيه مصري",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                : SizedBox(),
            Container(
              color: Color(0xffeeeeee),
              height: seatsCost != 0.0 ? 1 : 0,
            ),
            SizedBox(
              height: seatsCost != 0.0 ? 5 : 0,
            ),

            childrenSeatsNumbers != 0.0
                ? Padding(
                    padding: EdgeInsets.only(right: 20, top: 15),
                    child: Text(
                      'اجمالي تكلفة مقاعد الاطفال',
                      style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: childrenSeatsCost != 0.0 ? 5 : 0,
            ),
            childrenSeatsNumbers != 0.0
                ? Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 15),
                    child: Text(
                      Validation.replaceArabicNumber(
                              ((childrenSeatsNumbers ?? 0) *
                                      (_trip.children_chair_price ?? 0))
                                  .toString()) +
                          "  جنيه مصري",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                : SizedBox(),
            Container(
              color: Color(0xffeeeeee),
              height: childrenSeatsCost != 0.0 ? 1 : 0,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 15),
              child: Text(
                'المبلغ الإجمالي (كلي)',
                style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                Validation.replaceArabicNumber(_totalCost.toString()) +
                    "  جنيه مصري",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            // Container(
            //   color: Color(0xffeeeeee),
            //   height:  1 ,
            // ),
            // Padding(
            //   padding: EdgeInsets.only(right: 20, top: 15),
            //   child: Text(
            //     ' رسوم الدفع الإلكتروني 2% ',
            //     style: TextStyle(fontSize: 14, color: Color(0xff43a047)),
            //   ),
            // ),
            // SizedBox(
            //   height: 5,
            // ),
            // Padding(
            //   padding: EdgeInsets.only(right: 20),
            //   child: Text(
            //     Validation.replaceArabicNumber( ((_totalCost*2)/100).toString() )+ "  جنيه مصري",
            //     style: TextStyle(fontSize: 16, color: Colors.black),
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
//        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 5.0,
              // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOnlinePaymentButton() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Container(
//                    width: 300,
            height: 55,
            child: Center(
              child: Text(
                'الدفع الان',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 8.0,
                  // has the effect of softening the shadow
                  spreadRadius: 5.0,
                  // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    0.0, // vertical, move down 10
                  ),
                ),
              ],
              color: _isTermsAccepted ? Color(0xffff5c46) : Color(0xffbfbfbf),
            ),
          ),
        ),
        onTap: () => _onlinePaymentAction());
  }

  Widget _buildOfflinePaymentButton() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Container(
//                    width: 300,
            height: 55,
            child: Center(
              child: Text(
                _isSuccessOffline ? 'العودة إلى جميع الرحلات' : 'الدفع لاحقاً',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 8.0,
                  // has the effect of softening the shadow
                  spreadRadius: 5.0,
                  // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    0.0, // vertical, move down 10
                  ),
                ),
              ],
              color:
                  (!_isSuccessOffline && _isTermsAccepted && !_isEarlyPayment)
                      ? Color(0xff76d275)
                      : Color(0xffbfbfbf),
            ),
          ),
        ),
        onTap: () => _isEarlyPayment ? () {} : _offlinePaymentAction());
  }

  Widget _buildConfirmationMessage() {
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Text(
              _paymentOfflineNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffa70000),
                fontSize: 14,
              ),
            ),
          ),
          width: width - 40,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Text(
              'وإلا يعتبر الحجز لاغياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xffa70000),
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          width: width - 40,
        ),
      ],
    );
  }

  Widget _buildTicketButton() {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 0),
                child: Container(
                  width: 130,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  child: Center(
//                    child: Image.asset('assets/view.png'),
                    child: Text(
                      'عرض التذكرة',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.2),
                        blurRadius: 8.0,
                        // has the effect of softening the shadow
                        spreadRadius: 5.0,
                        // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          0.0, // vertical, move down 10
                        ),
                      ),
                    ],
                    color: Color(0xffff5c46),
                  ),
                ),
              ),
            ),
            onTap: () => _viewTicketAction()),
//        GestureDetector(
//          child: Center(
//            child: Padding(
//              padding: EdgeInsets.only(left: 0, right: 10),
//              child: Container(
//                width: 110,
//                padding: EdgeInsets.only(left: 20, right: 20),
//                height: 50,
//                child: Center(
//                  child: Image.asset('assets/send.png'),
//                ),
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(10),
//                  boxShadow: [
//                    BoxShadow(
//                      color: Colors.grey.withOpacity(.2),
//                      blurRadius: 8.0,
//                      // has the effect of softening the shadow
//                      spreadRadius: 5.0,
//                      // has the effect of extending the shadow
//                      offset: Offset(
//                        0.0, // horizontal, move right 10
//                        0.0, // vertical, move down 10
//                      ),
//                    ),
//                  ],
//                  color: Color(0xff43a047),
//                ),
//              ),
//            ),
//          ),
//          onTap: () => Navigator.of(context).push(PageRouteBuilder(
//              opaque: false,
//              pageBuilder: (BuildContext context, _, __) => SendInvoice())),
//        ),
      ],
    );
  }

  Widget _buildBackToTripsButton() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Container(
//                    width: 300,
            height: 55,
            child: Center(
              child: Text(
                'العودة إلى جميع الرحلات',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 8.0,
                  // has the effect of softening the shadow
                  spreadRadius: 5.0,
                  // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    0.0, // vertical, move down 10
                  ),
                ),
              ],
              color: Color(0xff76d275),
            ),
          ),
        ),
        onTap: () => _backToAllTrips());
  }

  bool _isValidationSuccess = true;

  void _offlinePaymentAction() {
    _isValidationSuccess = true;
    if (_isSuccessOffline) {
      if (_reloadTripsDelagate != null) {
        _reloadTripsDelagate?.reloadTripsAfterBooking(null);
      }
      if (_isFromPushNotification) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    TripsList(_isFromPushNotification, true)),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).popUntil(ModalRoute.withName('TripsList'));
      }
    } else {
      if (_isTermsAccepted) {
        if (_trip.min_deposite != null && _isEarlyPayment) {
          if (double.parse(_earlyPaymentController.text == ""
                  ? "0"
                  : _earlyPaymentController.text) <
              (_trip.min_deposite ?? 0)) {
            _isValidationSuccess = false;
            Fluttertoast.showToast(
              msg:
                  "اقل مقدم هو ${Validation.replaceArabicNumber(_trip.min_deposite.toString())} ",
            );
          }
        }
        if (_trip.max_deposite != null && _isEarlyPayment) {
          if (double.parse(_earlyPaymentController.text == ""
                  ? "0"
                  : _earlyPaymentController.text) >
              (_trip.max_deposite ?? 0)) {
            _isValidationSuccess = false;
            Fluttertoast.showToast(
              msg:
                  "اعلى مقدم هو ${Validation.replaceArabicNumber(_trip.max_deposite.toString())} ",
            );
          }
        }
        if (_isValidationSuccess) {
          _bookingNetwork.requestPayment(
              _selectedRoomsList,
              _selectedSeatsList,
              _selectedIDsList,
              nonFollowersIdsList,
              _trip,
              true,
              _bookingRequest,
              _email,
              widget._phone1,
              widget._phone2,
              widget._phone3,
              _isEarlyPayment ? _earlyPaymentController.text : "",
              addedGuests,
              childrenSeatsNumbers ?? 0,
              this);
        }
      }
    }
  }

  void _backToAllTrips() {
    if (_reloadTripsDelagate != null) {
      _reloadTripsDelagate?.reloadTripsAfterBooking(null);
    }
    if (_isFromPushNotification) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  TripsList(_isFromPushNotification, true)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('TripsList'));
    }
  }

  void _onlinePaymentAction() {
    _isValidationSuccess = true;
    if (_isTermsAccepted) {
      if (_isTermsAccepted) {
        if (_trip.min_deposite != null && _isEarlyPayment) {
          if (double.parse(_earlyPaymentController.text == ""
                  ? "0"
                  : _earlyPaymentController.text) <
              (_trip.min_deposite ?? 0)) {
            _isValidationSuccess = false;
            Fluttertoast.showToast(
              msg: "المبلغ لابد ان يكون اكبر من ${_trip.min_deposite} ",
            );
          }
        }
        if (_trip.max_deposite != null && _isEarlyPayment) {
          if (double.parse(_earlyPaymentController.text == ""
                  ? "0"
                  : _earlyPaymentController.text) >
              (_trip.max_deposite ?? 0)) {
            _isValidationSuccess = false;
            Fluttertoast.showToast(
              msg: "المبلغ لابد ان يكون اقل من ${_trip.max_deposite} ",
            );
          }
        }
        if (_isValidationSuccess) {
          _bookingNetwork.requestPayment(
              _selectedRoomsList,
              _selectedSeatsList,
              _selectedIDsList,
              nonFollowersIdsList,
              _trip,
              false,
              _bookingRequest,
              _email,
              widget._phone1,
              widget._phone2,
              widget._phone3,
              _isEarlyPayment ? _earlyPaymentController.text : "",
              addedGuests,
              childrenSeatsNumbers ?? 0,
              this);
        }
      }
    }
  }

  void _viewTicketAction() async {
    print(_ticketUrl);
    print(_ticketUrl);
    if (await UrlLauncher.canLaunch(_ticketUrl)) {
      if (Platform.isIOS) {
        await UrlLauncher.launch(_ticketUrl, forceSafariVC: false);
      } else {
        await UrlLauncher.launch(_ticketUrl);
      }
    } else {
      print("can't launch");
    }
  }

  String _getMembersIDs() {
    String ids = "";
    for (String id in _selectedIDsList) {
      ids += id;
      if (id != _selectedIDsList[_selectedIDsList.length - 1]) {
        ids += " ,";
      }
    }
    return ids;
  }

  String _getNonMembersIDs() {
    String ids = "";
    for (String id in nonFollowersIdsList) {
      ids += id;
      if (id != nonFollowersIdsList[nonFollowersIdsList.length - 1]) {
        ids += " ,";
      }
    }
    return ids;
  }

  double _getRoomsCost() {
    double cost = 0.0;
    for (TripRoomType roomType in _selectedRoomsList) {
      if (roomType.selectedCapacity != null &&
          roomType.selectedRoomView != null
      ) {
       int selectedCapacity =(roomType.selectedCapacity ?? 0)- (roomType.guestCount ?? 0);
        if ((roomType.selectedRoomView?.room_price ?? 0) != null) {
          cost += selectedCapacity *
              (roomType.selectedRoomView?.room_price ?? 0);
        }
      }
    }
    return cost;
  }
  double _getGuestRoomsCost() {
    double cost = 0.0;
    for (TripRoomType roomType in _selectedRoomsList) {
      if (roomType.isContainGuests??false ) {
        if ((roomType.selectedRoomView?.room_guest_price ?? 0) != null) {
          cost += (roomType.guestCount ?? 0) *
              (roomType.selectedRoomView?.room_guest_price ?? 0);
        }
      }
    }
    return cost;
  }

  double _getSeatsCost() {
    double cost = 0.0;
    for (SeatType seat in _selectedSeatsList) {
      if (seat.type_price != null) {
        cost += seat.type_price ?? 0;
      }
    }
    return cost;
  }

  double _getChildrenSeatsCost() {
    return double.parse(
        (_trip.children_chair_price ?? 0) * childrenSeatsNumbers); //cost;
  }

  String _setEndPaymentTime(String endDataStr) {
    String _paymentNote = "يتم التأكيد بالدفع حتى ";
    final endDateFormat = DateTime.parse(endDataStr);

    intl.DateFormat dateFormat = intl.DateFormat("dd-MM-yyyy");
    String dateFormatted = dateFormat.format(endDateFormat);

    intl.DateFormat timeFormat = intl.DateFormat("hh:mm a");
    String timeFormatted = timeFormat.format(endDateFormat);

    _paymentNote = _paymentNote + dateFormatted + "  حتى الساعة  ";
    print(
        'dateFormatted: ' + dateFormatted + " timeFormatted: " + timeFormatted);
    if (timeFormatted.contains('PM')) {
      print(timeFormatted.split(" ")[0]);
      _paymentNote = _paymentNote + timeFormatted.split(" ")[0] + " مساءاً ";
    } else if (timeFormatted.contains('AM')) {
      print(timeFormatted.split(" ")[0]);
      _paymentNote = _paymentNote + timeFormatted.split(" ")[0] + " صباحاً";
    }
    return _paymentNote;
  }

  void _setTimer() {
    int difference = 0;
    if (_bookingRequest.expired_at != null) {
      final endTime =
          DateTime.parse(_bookingRequest.expired_at ?? "2000-01-01");
      final date2 = DateTime.now();
      if (endTime.isAfter(date2)) {
        difference = endTime.difference(date2).inSeconds;
//        print("difference: " + difference.toString());
      } else {
//        print('before');
      }
    }
    int remainsDuration = difference;
    if (remainsDuration > 0) {
      setState(() {
        _timerValue = formatHHMMSS(remainsDuration);
      });
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        remainsDuration -= 1;
        setState(() {
          _timerValue = formatHHMMSS(remainsDuration);
        });
        if (remainsDuration <= 0) {
          print('end timer');
          timer.cancel();
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            print('navigate to end payment');
            if (!_isSuccessOffline && !_isSuccessOnline) {
              Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      SessionExpired(_trip, _isFromPushNotification)));
            }
          }
        }
      });
    }
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

//    if (hours == 0) {
//      return "$minutesStr:$secondsStr";
//    }

    return "$hoursStr:$minutesStr:$secondsStr";
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
    Fluttertoast.showToast(
        msg: "حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg: msg ?? "", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void showSuccessOffline(OfflinePayment? data) {
    if (data?.schedual_paied_at != null) {
      setState(() {
        _isSuccessOffline = true;
        _paymentOfflineNote = _setEndPaymentTime(data?.schedual_paied_at ?? "");
      });
    }
  }

  @override
  void showSuccessOnline(OnlinePayment? data) {
//    _bookingNetwork.requestOnlinePayment(_totalCost * 100, _email, this);
    if (data?.extendedExpireTime != null) {
      extendTime(data?.extendedExpireTime ?? "");
    }
    if (data?.iframeUrl != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => OnlineWebPayment(
                  data?.iframeUrl ?? "",
                  _trip,
                  _bookingRequest,
                  _isFromPushNotification,
                  this)));
    }
  }

  @override
  void extendTime(String time) {
    print('extendTime payment type');
    setState(() {
      _bookingRequest.expired_at = time;
    });
    if (_onlinePaymentDelegate != null) {
      _onlinePaymentDelegate?.extendTime(time);
    }
  }

  @override
  void showSuccessOnlinePayment(String url) {
    setState(() {
      _isSuccessOnline = true;
      _ticketUrl = url;
    });
  }
}
