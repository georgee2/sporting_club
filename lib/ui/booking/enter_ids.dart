import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/trips/available_room_views.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/follow_member.dart';
import 'package:sporting_club/data/model/trips/guest.dart';
import 'package:sporting_club/data/model/trips/other_member.dart';
import 'package:sporting_club/data/model/trips/seat_type.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_price.dart';
import 'package:sporting_club/data/model/trips/trip_room_type.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/delegates/online_payment_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/FollowMembersResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/ui/booking/payment_type.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EnterIDs extends StatefulWidget {
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  List<TripRoomType> _selectedRoomsList = [TripRoomType()];
  List<String> nonFollowersIdsList = [];
  List<SeatType> _selectedSeatsList = [];
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  OnlinePaymentDelegate _onlinePaymentDelegate;
  List<Guest> addedGuests;

  EnterIDs(
    this._trip,
    this._bookingRequest,
    this._selectedSeatsList,
    this._selectedRoomsList,
    this.nonFollowersIdsList,
    this.addedGuests,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
    this._onlinePaymentDelegate,
  );

  @override
  State<StatefulWidget> createState() {
    return EnterIDsState(
      this._trip,
      this._bookingRequest,
      this._selectedSeatsList,
      this._selectedRoomsList,
      this.nonFollowersIdsList,
      this.addedGuests,
      this._reloadTripsDelagate,
      this._isFromPushNotification,
      this._onlinePaymentDelegate,
    );
  }
}

class EnterIDsState extends State<EnterIDs>
    implements OnlinePaymentDelegate, FollowMembersResponseListener {
  bool _isloading = false;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;

  List<TripRoomType> _selectedRoomsList = [TripRoomType()];
  List<String> nonFollowersIdsList = [];
  List<SeatType> _selectedSeatsList = [];

  List<String> _selectedIDsList = [];
  var _controllers = <TextEditingController>[];
  var _emailController = TextEditingController();
  var _phone1Controller = TextEditingController();
  var _phone2Controller = TextEditingController();
  var _phone3Controller = TextEditingController();
  bool _isMembersOnly = false;
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  Timer? timer;
  String _timerValue = "";
  Validation _validation = Validation();
  OnlinePaymentDelegate? _onlinePaymentDelegate;
  List<Guest>? addedGuests;
  User user = User();
  List<DropdownMenuItem<int>> _childrenBusSeatsCapacityDropdownItems = [];
  int avaliable_additional_seat_num = 0;
  int additional_seat_num = 0;
  bool hasChildrenSeats = false;

  EnterIDsState(
    this._trip,
    this._bookingRequest,
    this._selectedSeatsList,
    this._selectedRoomsList,
    this.nonFollowersIdsList,
    this.addedGuests,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
    this._onlinePaymentDelegate,
  );

  BookingNetwork _bookingNetwork = BookingNetwork();

  @override
  void initState() {
    //_emailController.text = "";

    _bookingNetwork.getFollowMembers(this, _trip.id);
    _emailController.text = LocalSettings.user?.user_email ?? "";

    if (_trip.accept_none_membership != null) {
      _isMembersOnly = !(_trip.accept_none_membership ?? false);
    }
    if (_isMembersOnly && _bookingRequest.seats_count != null) {
      _selectedIDsList = new List<String>.generate(
          (_bookingRequest.seats_count ?? 0), (i) => "");
      _controllers = new List<TextEditingController>.generate(
          (_bookingRequest.seats_count ?? 0),
          (i) => TextEditingController(text: ""));
    }
    _membershipIdController.text =
        LocalSettings.user?.membership_no.toString() ?? "";
    _getUserMembershipID();

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (timer != null) {
      timer?.cancel();
    }
    _setTimer();
    return ModalProgressHUD(
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
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          backgroundColor: Color(0xfff9f9f9),
          bottomNavigationBar: _buildFooter(),
          body: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: _buildContent(),
          ),
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
    return ListView(
      children: <Widget>[
        _buildHeader(),
        Container(
          color: Color(0xffeeeeee),
          height: 1,
        ),

        // _buildIDsList(),
        //    :
        // _buildMembershipNumberField(),
        Container(
          padding: EdgeInsets.only(right: 20),
          height: 50,
          child: Align(
              child: Text(
                "قم باختيار ارقام الاعضاء",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),

        _buildFollowMembersList(),
        SizedBox(
          height: 10,
        ),
        (_trip.accept_none_followers ?? false)
            ? _buildOtherMembersTitle()
            : SizedBox(),
        hasOtherMembers ? _buildOtherMemberList() : SizedBox(),

        // (_selectedSeatsList.length > 0 && _trip.children_chair_price != null)
        //     ? _buildChildrenSeats()
        //     : SizedBox(),
        _trip.enable_bus_seat_age_limit && avaliable_additional_seat_num > 0
            ? _buildBusChildrenSeats()
            : SizedBox(),
        Container(
          padding: EdgeInsets.only(right: 20, top: 20),
          margin: EdgeInsets.only(bottom: 10),
          height: 45,
          child: Align(
              child: Text(
                "ادخل البريد الإلكتروني ",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        _buildEmailField(),
        _buildPhoneField(
            phoneLabel: "رقم الهاتف الاول",
            textEditingController: _phone1Controller),
        _buildPhoneField(
            phoneLabel: "رقم الهاتف الثاني",
            textEditingController: _phone2Controller),
        _buildPhoneField(
            phoneLabel: "رقم الهاتف الثالت",
            textEditingController: _phone3Controller),

        // Container(
        //   padding: EdgeInsets.only(right: 20),
        //   height: 70,
        //   child: Align(
        //       child: Text(
        //         "قم بادخال رقم العضوية",
        //         style: TextStyle(
        //             color: Colors.grey,
        //             fontSize: 17,
        //             fontWeight: FontWeight.w700),
        //       ),
        //       alignment: Alignment.centerRight),
        // ),
        Container(
          color: Color(0xffeeeeee),
          height: 1,
        ),
        // GestureDetector(
        //   child: Align(
        //     child: Padding(
        //       padding: EdgeInsets.only(top: 10, left: 20),
        //       child: Row(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: <Widget>[
        //           Image.asset(
        //             'assets/add_room.png',
        //             width: 20,
        //             height: 20,
        //             fit: BoxFit.fitWidth,
        //           ),
        //           SizedBox(
        //             width: 8,
        //           ),
        //           Text(
        //             'اضف رقم العضوية',
        //             style: TextStyle(
        //                 color: Color(0xff00701a),
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w700),
        //           ),
        //         ],
        //       ),
        //     ),
        //     alignment: Alignment.centerLeft,
        //   ),
        //   onTap: () => showDialog(),
        // ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  int childrenSeatsNumbers = 0;
  List<DropdownMenuItem<int>> _childrenSeatsCapacityDropdownItems = [];

  Widget _buildChildrenSeatsDropDown() {
    double width = MediaQuery.of(context).size.width;
    _childrenSeatsCapacityDropdownItems.clear();
    for (int index = 0; index <= _selectedSeatsList.length; index++) {
      _childrenSeatsCapacityDropdownItems.add(
        DropdownMenuItem(
          value: index,
          child: Align(
            child: Container(
//              child: Center(
              child: Text(
                index.toString(),
                textAlign: TextAlign.right,
              ),

//              ),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 80,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: new Text("0"),
                  value: childrenSeatsNumbers,
                  items: _childrenSeatsCapacityDropdownItems,
                  onChanged: (int? guestNumbers) {
                    setState(() {
                      childrenSeatsNumbers = guestNumbers ?? 0;
                    });
                  },
                  icon: Image.asset('assets/dropdown_ic.png'),
                ),
              ),
            ),
//            width: 65,
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
        color: Colors.white,
      ),
      height: 40,
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 0, top: 5),
    );
  }

  Widget _buildChildrenSeats() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'حجز كرسي لطفل',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            SizedBox(
              width: 10,
            ),
            _buildChildrenSeatsDropDown(),
            Text(
              'كرسي/طفل',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        height: 50,
        color: Color(0xffeeeeee),
      ),
    );
  }

  Widget _buildBusChildrenSeats() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
      ),
      child: Container(
          height: hasChildrenSeats ? 100 : 50,
          color: Color(0xffeeeeee),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: hasChildrenSeats,
                  onChanged: (val) {
                    setState(() {
                      hasChildrenSeats = !hasChildrenSeats;
                    });
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'يمكنك حجز مقعد إضافي للأطفال دون سن ${_trip.bus_seat_age_limit}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            hasChildrenSeats
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      _buildBUSSeatsDropDown(),
                      Text(
                        'كرسي/طفل',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ])
          //

          ),
    );
  }

  Widget _buildBUSSeatsDropDown() {
    double width = MediaQuery.of(context).size.width;
    _childrenBusSeatsCapacityDropdownItems.clear();
    for (int index = 1; index <= avaliable_additional_seat_num; index++) {
      _childrenBusSeatsCapacityDropdownItems.add(
        DropdownMenuItem(
          value: index,
          child: Align(
            child: Container(
//              child: Center(
              child: Text(
                index.toString(),
                textAlign: TextAlign.right,
              ),

//              ),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: 200,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: new Text(
                    "اختر عدد المقاعد",
                    style: TextStyle(color: Colors.black),
                  ),
                  disabledHint: new Text(
                    "اختر عدد المقاعد",
                    style: TextStyle(color: Colors.black),
                  ),
                  value: additional_seat_num == 0 ? null : additional_seat_num,
                  items: _childrenBusSeatsCapacityDropdownItems,
                  onChanged: (int? guestNumbers) {
                    setState(() {
                      additional_seat_num = guestNumbers ?? 0;
                    });
                  },
                  icon: Image.asset('assets/dropdown_ic.png'),
                ),
              ),
            ),
//            width: 65,
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
        color: Colors.white,
      ),
      height: 40,
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 0, top: 5),
    );
  }

  void showDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: _buildFollowMembersList(),
            margin: EdgeInsets.only(top: 15, bottom: 0, left: 3, right: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
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
          'assets/header_step2.png',
//          width: viewWidth,
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

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          right: 20,
          left: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
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
//                CountDownTimer(
//                  secondsRemaining: difference,
//                  countDownTimerStyle: TextStyle(
//                      color: Color(0xff03240a),
//                      fontSize: 14,
//                      fontWeight: FontWeight.w700),
//                  whenTimeExpires: () {
//                    setState(() {
//                      print('time endddddddd');
//                      Navigator.of(context).push(PageRouteBuilder(
//                          opaque: false,
//                          pageBuilder: (BuildContext context, _, __) =>
//                              SessionExpired()));
//                    });
//                  },
//                ),
//
                Text(
                  _timerValue,
                  style: TextStyle(
                      color: Color(0xff03240a),
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, right: 10),
                  child: Container(
                    width: 88,
                    height: 50,
                    child: Center(
                      child: Text(
                        'التالي',
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
                      color: Color(0xffff5c46),
                    ),
                  ),
                ),
                onTap: () => _navigateToNextAction()),
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

  Widget _buildIDTitle(int index) {
    int number = index + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "عضوية",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Color(0xff43a047),
          ),
          height: 22,
          width: 22,
        ),
        Expanded(
          child: Container(),
        ),
        _isMembersOnly
            ? SizedBox()
            : index != 0
                ? GestureDetector(
                    child: Align(
                      child: Image.asset('assets/grey_close_ic.png'),
                      alignment: Alignment.centerLeft,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIDsList.removeAt(index);
                        _controllers.removeAt(index);
                      });
                    },
                  )
                : SizedBox(),
        SizedBox(
          width: 5,
        ),
        _isMembersOnly
            ? SizedBox()
            : index != 0
                ? GestureDetector(
                    child: Align(
                      child: Text(
                        'الغاء',
                        style: TextStyle(
                            color: Color(0xff212121),
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIDsList.removeAt(index);
                        _controllers.removeAt(index);
                      });
                    },
                  )
                : SizedBox(),
      ],
    );
  }

  Widget _buildIDsList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedIDsList.length,
        itemBuilder: (context, i) {
          return new Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ExpansionTile(
//                  trailing: Icon(Icons.arrow_downward),
                  title: Container(
                    child: _buildIDTitle(i),
                    color: Colors.white,
                  ),
                  initiallyExpanded: true,
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        _buildIDContent(i),
                      ],
                    ),
                  ],
                ),
                Container(
                  color: Color(0xffeeeeee),
                  height: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowMembersList() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
      padding: EdgeInsets.only(top: 5, bottom: 5),

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
      // height: 50,
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _followMembersList.length,
        itemBuilder: (context, i) {
          return new Container(
              // color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      value: (_selectedMembersList
                          .contains(_followMembersList[i].clubId)),
                      onChanged: (val) {
                        if (i != 0) {
                          if (_followMembersList[i].book_before ?? false) {
                            Fluttertoast.showToast(
                                msg: "لقد تم الحجز فى هذه الرحلة من قبل",
                                toastLength: Toast.LENGTH_LONG);
                          } else {
                            if (_followMembersList[i].accept_age ?? false) {
                              if (val ?? false) {
                                _selectedMembersList
                                    .add(_followMembersList[i].clubId ?? "");
                              } else {
                                _selectedMembersList
                                    .remove(_followMembersList[i].clubId);
                              }
                              setState(() {});
                            } else {
                              Fluttertoast.showToast(
                                  msg: "نعتذر السن غير مناسب لهذه الرحلة",
                                  toastLength: Toast.LENGTH_LONG);
                            }
                          }
                        }
                      },
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              _followMembersList[i].name ?? "",
                              style: TextStyle(
                                fontSize: i == 0 ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                color: (!(_followMembersList[i].accept_age ??
                                            false) ||
                                        (_followMembersList[i].book_before ??
                                            false))
                                    ? Color(0xffb2b2b2)
                                    : i == 0
                                        ? Color(0xff43a047)
                                        : Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              _followMembersList[i].clubId ?? "",
                              style: TextStyle(
                                fontSize: i == 0 ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                color: (!(_followMembersList[i].accept_age ??
                                            false) ||
                                        (_followMembersList[i].book_before ??
                                            false))
                                    ? Color(0xffb2b2b2)
                                    : i == 0
                                        ? Color(0xff43a047)
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ]),
                  ],
                ),
                ((_followMembersList[i].accept_age ?? false) &&
                        !Validation.isAdult(
                            _followMembersList[i].birthdate ?? "2000-01-01",
                            _trip.bus_seat_age_limit) &&
                        _trip.enable_bus_seat_age_limit)
                    ? Container(
                        child: Text(
                          "لم يتم حجز كرسي لهذا العضو فى الاتوبيس يمكنك اضافه كرسي بسعر ${Validation.replaceArabicNumber(_trip.children_chair_price.toString())} جنيه مصري",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff646464),
                          ),
                        ),
                        margin: EdgeInsets.only(left: 10, right: 47),
                      )
                    : SizedBox()
              ]));
        },
      ),
    );
  }

  Widget _buildIDContent(int index) {
    return Container(
      color: Colors.white,
//      height: 300,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Container(
              child: TextField(
                controller: _controllers[index],
                textAlign: TextAlign.right,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'رقم العضوية',
                ),
                keyboardType: TextInputType.number,
                keyboardAppearance: Brightness.light,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
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
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  var _membershipIdController = TextEditingController();

  Widget _buildMembershipNumberField() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: TextField(
            controller: _membershipIdController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'رقم العضوية',
            ),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
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

  Widget _buildEmailField() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: TextField(
            controller: _emailController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'البريد الإلكتروني',
            ),
            keyboardType: TextInputType.emailAddress,
            keyboardAppearance: Brightness.light,
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

  Widget _buildPhoneField(
      {TextEditingController? textEditingController, String? phoneLabel}) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 20, top: 20),
          margin: EdgeInsets.only(bottom: 10),
          height: 45,
          child: Align(
              child: Text(
                phoneLabel ?? "",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Container(
              child: TextField(
                controller: textEditingController,
                textAlign: TextAlign.right,
                maxLength: 11,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: phoneLabel,
                  counterText: "",
                ),
                keyboardType: TextInputType.phone,
                keyboardAppearance: Brightness.light,
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
        ),
      ],
    );
  }

  bool hasOtherMembers = false;

  Widget _buildOtherMembersTitle() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              child: (hasOtherMembers)
                  ? Icon(
                      Icons.check_box,
                      color: Color(0xffff5c46),
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      color: Color(0xffbfbfbf),
                    ),
              onTap: () {
                hasOtherMembers = !hasOtherMembers;
                if (hasOtherMembers &&
                    _otherMembershipIdController.length == 0) {
                  // _otherMembersList.add("");
                  _otherMembershipIdController.add(TextEditingController());
                }
                if (hasOtherMembers) {
                  avaliable_additional_seat_num = avaliable_additional_seat_num + memberNameMap.length;
                  additional_seat_num = 0;
                } else {
                  avaliable_additional_seat_num = avaliable_additional_seat_num - memberNameMap.length;
                  additional_seat_num = 0;
                }
                setState(() {});
              },
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'أضف اعضاء أخرين',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(
                      (hasOtherMembers &&
                              _otherMembershipIdController.length <
                                  _trip.number_non_followers)
                          ? 'assets/add_ic_ac.png'
                          : 'assets/add_ic_nr.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'عضو اخر',
                      style: TextStyle(
                          color: (hasOtherMembers &&
                                  _otherMembershipIdController.length <
                                      _trip.number_non_followers)
                              ? Color(0xff43a047)
                              : Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              onTap: () {
                if (hasOtherMembers &&
                    _otherMembershipIdController.length <
                        _trip.number_non_followers) {
                  bool addAnotherMember = true;
                  for (int i = 0;
                      i < (_otherMembershipIdController.length);
                      i++) {
                    if (_otherMembershipIdController[i].value.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال اسم العضو",
                          toastLength: Toast.LENGTH_LONG);
                      addAnotherMember = false;
                    }
                  }
                  if (hasOtherMembers && addAnotherMember) {
                    // _otherMembersList.add("");
                    _otherMembershipIdController.add(TextEditingController());
                    setState(() {});
                  }
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        height: 50,
        color: Color(0xffeeeeee),
      ),
    );
  }

  Widget _buildOtherMemberList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _otherMembershipIdController.length,
        itemBuilder: (context, i) {
          return _buildOtherMemberItem(i);
        },
      ),
    );
  }

  List<TextEditingController> _otherMembershipIdController = [];
  Map<String, OtherMembers?> memberNameMap = {};

  Widget _buildOtherMemberItem(int index) {
    return new Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Color(0xffd4d4d4),
            height: 1,
          ),
          Container(
            color: Color(0xffeeeeee),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(right: 15, top: 15, bottom: 5),
                        width: 90,
                        child: Text(
                          "رقم العضو",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        )),
                    Row(
                      children: [
                        index != 0
                            ? GestureDetector(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 18),
                                  child: Align(
                                    child:
                                        Image.asset('assets/grey_close_ic.png'),
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    // _otherMembersList.removeAt(index);
                                    memberNameMap.remove(
                                        _otherMembershipIdController[index]
                                            .text);
                                    avaliable_additional_seat_num =
                                        avaliable_additional_seat_num - 1;
                                    additional_seat_num = 0;
                                    _otherMembershipIdController
                                        .removeAt(index);
                                  });
                                },
                              )
                            : SizedBox(),
                        SizedBox(
                          width: 5,
                        ),
                        index != 0
                            ? GestureDetector(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Align(
                                    child: Text(
                                      'الغاء',
                                      style: TextStyle(
                                          color: Color(0xff212121),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    // _otherMembersList.removeAt(index);
                                    memberNameMap.remove(
                                        _otherMembershipIdController[index]
                                            .text);
                                    avaliable_additional_seat_num =
                                        avaliable_additional_seat_num - 1;
                                    additional_seat_num = 0;
                                    _otherMembershipIdController
                                        .removeAt(index);
                                  });
                                },
                              )
                            : SizedBox(),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildInputField(
                        "رقم العضو",
                        _otherMembershipIdController[index],
                        TextInputType.number,
                        onTap: () {}, onChange: (value) {
                      if (value?.length == 12) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _bookingNetwork.getMemberNameById(value ?? "",_trip.id??0 , this );
                      }
                    }),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(right: 15, top: 5, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      memberNameMap[_otherMembershipIdController[index].text] ==
                              null
                          ? SizedBox()
                          : Icon(
                              Icons.check_box,
                              color: Color(0xffff5c46),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ((_otherMembershipIdController[index]
                                          .text
                                          .isNotEmpty) &&
                                      memberNameMap[
                                              _otherMembershipIdController[index]
                                                  .text] ==
                                          null)
                                  ? "رقم عضوية غير صحيح"
                                  : memberNameMap[
                                          _otherMembershipIdController[index]
                                              .text]?.name ??
                                      "",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width-100,
                              child: Text(
                                memberNameMap[
                                _otherMembershipIdController[index]
                                    .text]?.message ??
                                    "",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String title, TextEditingController controller, TextInputType type,
      {enable = true,
      List<TextInputFormatter>? inputFormatters,
      required Function onTap,
      Function(String?)? onChange}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Container(
            child: TextField(
              onChanged: onChange,
              enabled: enable,
              controller: controller,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.right,
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              ),
              keyboardType: type,
              keyboardAppearance: Brightness.light,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(.2),
              //     blurRadius: 8.0,
              //     // has the effect of softening the shadow
              //     spreadRadius: 5.0,
              //     // has the effect of extending the shadow
              //     offset: Offset(
              //       0.0, // horizontal, move right 10
              //       0.0, // vertical, move down 10
              //     ),
              //   ),
              // ],
              color: Colors.white,
            ),
            height: 50,
            margin: EdgeInsets.only(bottom: 5, top: 10),
            padding: EdgeInsets.all(1),
          ),
        ),
      ),
    );
  }

  bool validateOtherMembers() {
    bool validOtherMember = true;
    if (hasOtherMembers &&
        this.memberNameMap.keys.isNotEmpty &&
        this.memberNameMap.keys.length == _otherMembershipIdController.length) {
      validOtherMember = true;
    } else if (!hasOtherMembers) {
      validOtherMember = true;
    } else {
      validOtherMember = false;
    }
    return validOtherMember;
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
            print('navigate to end enter ids');
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    SessionExpired(_trip, _isFromPushNotification)));
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

  void _navigateToNextAction() {
    if (validateOtherMembers()) {
      if (_validateIDs()) {
        print("valid ids");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaymentType(
                      this._trip,
                      this._bookingRequest,
                      this._selectedSeatsList,
                      this._selectedRoomsList,
                      this._selectedMembersList,
                      this.memberNameMap.keys.toList(),
                      // this._selectedIDsList,
                      this.addedGuests ?? [],
                      (hasChildrenSeats && this.additional_seat_num > 0)
                          ? this.additional_seat_num
                          : 0,
                      this._reloadTripsDelagate,
                      this._isFromPushNotification,
                      this._emailController.text,
                      this._phone1Controller.text,
                      this._phone2Controller.text,
                      this._phone3Controller.text,
                      this,
                    )));
      }
    } else {
      int numOfInValidMembers =
          _otherMembershipIdController.length - memberNameMap.length;
      if (numOfInValidMembers > 0) {
        String errorMsg = "رقم العضوية غير صحيح";
        Fluttertoast.showToast(msg: errorMsg, toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(
            msg: 'برجاء استكمال بيانات غير الاعضاء بشكل صحيح',
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }

  void _getUserMembershipID() {
    if (LocalSettings.user != null) {
      if (LocalSettings.user?.membership_no != null) {
        if (_isMembersOnly) {
          _selectedIDsList[0] =
              LocalSettings.user?.membership_no.toString() ?? "";
        } else {
          _selectedIDsList
              .add(LocalSettings.user?.membership_no.toString() ?? "");
        }
      } else {
        if (_isMembersOnly) {
          _selectedIDsList[0] = '';
        } else {
          _selectedIDsList.add('');
        }
      }
    } else {
      if (_isMembersOnly) {
        _selectedIDsList[0] = '';
      } else {
        _selectedIDsList.add('');
      }
    }
    var textEditingController =
        new TextEditingController(text: _selectedIDsList[0]);
    if (_isMembersOnly) {
      _selectedIDsList[0] = '';
      _controllers[0] = textEditingController;
    } else {
      _controllers.add(textEditingController);
    }
  }

  void _addNewID() {
    setState(() {
      _selectedIDsList.add('');
      var textEditingController = new TextEditingController(
          text: _selectedIDsList[_selectedIDsList.length - 1]);
      _controllers.add(textEditingController);
    });
  }

  bool _validateIDs() {
    if (_emailController.text.isEmpty) {
      print("empty email");
      Fluttertoast.showToast(
          msg: 'برجاء ادخال البريد الإلكتروني', toastLength: Toast.LENGTH_LONG);
      return false;
    } else if (!_validation.isEmail(_emailController.text)) {
      Fluttertoast.showToast(
          msg: 'برجاء ادخال بريد إلكتروني صحيح',
          toastLength: Toast.LENGTH_LONG);
      return false;
    }
    if ((_phone1Controller.text.isEmpty && _phone2Controller.text.isEmpty) ||
        (_phone1Controller.text.isEmpty && _phone3Controller.text.isEmpty) ||
        (_phone2Controller.text.isEmpty && _phone3Controller.text.isEmpty)) {
      print("empty _phone1Controller");
      Fluttertoast.showToast(
          msg: ' من فضلك يجب اضافة رقمين', toastLength: Toast.LENGTH_LONG);
      return false;
    } else if ((_phone1Controller.text.isNotEmpty &&
            !_isValidaPhoneNumber(_phone1Controller.text)) ||
        (_phone2Controller.text.isNotEmpty &&
            !_isValidaPhoneNumber(_phone2Controller.text)) ||
        (_phone3Controller.text.isNotEmpty &&
            !_isValidaPhoneNumber(_phone3Controller.text))) {
      Fluttertoast.showToast(
          msg: 'رقم الهاتف يجب أن يكون صالحا', toastLength: Toast.LENGTH_LONG);
      return false;
    }

    if (hasChildrenSeats && additional_seat_num == 0) {
      print("empty seats");
      Fluttertoast.showToast(
          msg: 'من فضلك اختار كرسي واحد على الأقل',
          toastLength: Toast.LENGTH_LONG);
      return false;
    }
    // for (int i = 0; i < _controllers.length; ++i) {
    //   _selectedIDsList[i] = _controllers[i].text;
    // }

    // if (_selectedIDsList.contains("")) {
    //   print("empty id");
    //   Fluttertoast.showToast(msg:'برجاء استكمال ارقام العضويات', context,
    //       duration: Toast.LENGTH_LONG);
    //   return false;
    // }

    // var distinctIds = _selectedIDsList.toSet().toList();
    // if (distinctIds.length < _selectedIDsList.length) {
    //   print("same ids");
    //   Fluttertoast.showToast(msg:'برجاء ادخال ارقام عضويات مختلفة', context,
    //       duration: Toast.LENGTH_LONG);
    //   return false;
    // }
    if (_selectedMembersList.isEmpty) {
      print("empty id");
      Fluttertoast.showToast(
          msg: 'برجاء استكمال ارقام العضويات', toastLength: Toast.LENGTH_LONG);
      return false;
    }
    return true;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }

    return double.tryParse(
          s,
        ) !=
        null;
  }

  static bool _isValidaPhoneNumber(String value) {
    // String pattern = r'(^(?:[+0])?[0-9]{11}$)';
    String pattern = r'(^[0-9]{1,11}$)';
    RegExp regExp = new RegExp(pattern);
    // bool validStartphoneNum= (value.toString().startsWith("010")||value.toString().startsWith("011")||value.toString().startsWith("012")||value.toString().startsWith("015"));
    return regExp.hasMatch(value);
  }

  @override
  void extendTime(String time) {
    print('extendTime enter ids');
    setState(() {
      _bookingRequest.expired_at = time;
    });
    if (_onlinePaymentDelegate != null) {
      _onlinePaymentDelegate?.extendTime(time);
    }
  }

  @override
  void hideLoading() {
    print("hide Loading");
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
    print("showNetworkError");
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

  FollowMembers? _currentFollowMember;
  List<FollowMembers> _followMembersList = [];
  List<String> _selectedMembersList = [];

  @override
  void setFollowMembers(FollowMembersData? followMembers) {
    _followMembersList = [];
    print("additional sets0000");

    _followMembersList.addAll(followMembers?.followMembers ?? []);
    for (FollowMembers item in _followMembersList) {
      print("additional 2222");
      if (!Validation.isAdult(
          item.birthdate ?? "2000-01-01", _trip.bus_seat_age_limit)) {
        avaliable_additional_seat_num = avaliable_additional_seat_num + 1;
        print("additional sets$avaliable_additional_seat_num");
      }
    }
    _followMembersList.removeWhere((element) {
      if (element.clubId == LocalSettings.user?.membership_no.toString()) {
        _currentFollowMember = element;
        return true;
      }
      return false;
    });

    if (_currentFollowMember != null) {
      _selectedMembersList.add(_currentFollowMember?.clubId ?? "");
      _followMembersList.insert(0, _currentFollowMember!);
    }

    //check_age
  }

  @override
  void showSuccessMemberName(OtherMembers? otherMembers, String MemberId) {
    print(otherMembers ?? "");
    memberNameMap[MemberId] = otherMembers;
    avaliable_additional_seat_num = avaliable_additional_seat_num + 1;

    setState(() {});
  }
}
