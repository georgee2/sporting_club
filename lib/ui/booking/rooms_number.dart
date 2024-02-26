import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/contacting_info.dart';
import 'package:sporting_club/data/model/trips/available_room_views.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/guest.dart';
import 'package:sporting_club/data/model/trips/seat_type.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_price.dart';
import 'package:sporting_club/data/model/trips/trip_room_type.dart';
import 'package:sporting_club/delegates/online_payment_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/utilities/app_colors.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'enter_ids.dart';

class RoomsNumber extends StatefulWidget {
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;

  RoomsNumber(
    this._trip,
    this._bookingRequest,
    this.screenWidth,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
  );

  @override
  State<StatefulWidget> createState() {
    return RoomsNumberState(
      this._trip,
      this._bookingRequest,
      this.screenWidth,
      this._reloadTripsDelagate,
      this._isFromPushNotification,
    );
  }
}

class RoomsNumberState extends State<RoomsNumber>
    implements OnlinePaymentDelegate, SeatsNumberResponseListener {
  bool _isloading = false;
  List<TripRoomType> _selectedRoomsList = [TripRoomType()];
  List<SeatType> _selectedSeatsList = [];
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  BookingNetwork _bookingNetwork = BookingNetwork();

  Map<int, List<DropdownMenuItem<TripRoomType>>> _roomTypesDropdownItems =
      Map<int, List<DropdownMenuItem<TripRoomType>>>();

  Map<int, List<DropdownMenuItem<AvailableRoomView>>> _roomViewsDropdownItems =
      Map<int, List<DropdownMenuItem<AvailableRoomView>>>();

  Map<int, List<DropdownMenuItem<int>>> _roomCapacityDropdownItems =
      Map<int, List<DropdownMenuItem<int>>>();

  Map<int, List<DropdownMenuItem<SeatType>>> _seatsTypesDropdownItems =
      Map<int, List<DropdownMenuItem<SeatType>>>();
  List<DropdownMenuItem<int>> _guestCapacityDropdownItems = [];
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;

//  int _roomsCount = 1;
  bool _hasChild = false;
  Timer? timer;
  String _timerValue = "";

  List<GlobalKey<AppExpansionTileState>> expansionTiles = [];

  List<GlobalKey<AppExpansionTileState>> expansionGuestTiles = [];

  RoomsNumberState(
    this._trip,
    this._bookingRequest,
    this.screenWidth,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
  );

  @override
  void initState() {
    _roomTypesDropdownItems.clear();
    _setRoomsList();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  double allScreenWidth = 0;

  @override
  Widget build(BuildContext context) {
    allScreenWidth = MediaQuery.of(context).size.width;
    if (timer != null) {
      timer?.cancel();
    }
    _setTimer();
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: WillPopScope(
          onWillPop: () async {
            print("here back press");
            _bookingNetwork.expireTrip(_bookingRequest.id ?? 0, this);
            Navigator.of(context).pop(null);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                _trip.name ?? "",
              ),
              leading: IconButton(
                  icon: new Image.asset('assets/back_white.png'),
                  onPressed: () {
                    print("here back press");
                    _bookingNetwork.expireTrip(_bookingRequest.id ?? 0, this);

                    Navigator.of(context).pop(null);
                  }),
            ),
            backgroundColor: Color(0xfff9f9f9),
            bottomNavigationBar: _buildFooter(),
            body: InkWell(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: _buildContent()),
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
          padding: EdgeInsets.only(right: 20),
          height: 70,
          child: Align(
              child: Text(
                'عدد الغرف (' + _selectedRoomsList.length.toString() + ")",
                style: TextStyle(
                    color: Color(0xff00701a),
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        Container(
          color: Color(0xffeeeeee),
          height: 1,
        ),
        _buildRoomsList(),
        GestureDetector(
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Image.asset(
                    'assets/add_room.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'اضف غرفة',
                    style: TextStyle(
                        color: Color(0xff00701a),
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
          onTap: () {
            setState(() {
              _addNewRoomToList();
            });
          },
        ),
        (_trip.accept_none_membership ?? false)
            ? _buildGuestTitle()
            : SizedBox(),
        hasGuest ? _buildGuestList() : SizedBox(),
        (_trip.formatted_seat_types?.length ?? 0) > 0
            ? _buildChildrenTitle()
            : SizedBox(),
        (_trip.formatted_seat_types?.length ?? 0) > 0
            ? _buildChildrenList()
            : SizedBox(),
        SizedBox(
          height: 10,
        ),
        // (_trip.accept_none_followers ?? false)
        //     ? _buildOtherMembersTitle()
        //     : SizedBox(),
        // hasOtherMembers ? _buildOtherMemberList() : SizedBox(),
        Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Text(
            'اضف تعليق',
            style: TextStyle(
                color: Color(0xff03240a).withOpacity(.8),
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ),
        _buildCommentField(),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  var _commentController = TextEditingController();

  Widget _buildCommentField() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: TextField(
            maxLines: 8,
            controller: _commentController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'اضف تعليق (اختياري)',
            ),
            keyboardType: TextInputType.multiline,
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
          height: 150,
          margin: EdgeInsets.only(bottom: 5, top: 10),
          padding: EdgeInsets.all(1),
        ),
      ),
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
//        child: Stack(
//          children: <Widget>[
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                Column(
//                  children: <Widget>[
//                    Container(
//                      child: Center(
//                        child: Text(
//                          '1',
//                          style: TextStyle(
//                              color: Colors.white,
//                              fontSize: 26,
//                              fontWeight: FontWeight.w700),
//                        ),
//                      ),
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(25),
//                        color: Color(0xff43a047),
//                      ),
//                      height: 50,
//                      width: 50,
//                    ),
//                    SizedBox(
//                      height: 5,
//                    ),
//                    Text(
//                      'تفاصيل الغرف',
//                      style: TextStyle(
//                          color: Color(0xff43a047),
//                          fontSize: 12,
//                          fontWeight: FontWeight.w700),
//                    ),
//                  ],
//                ),
//                SizedBox(
//                  width: 40,
//                ),
//                _buildNextStep("2", "ادخل ارقام العضويات"),
//                SizedBox(
//                  width: 40,
//                ),
//                _buildNextStep("3", 'طريقة الدفع'),
//              ],
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 25, right: 2),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  Container(
//                    width: 66,
//                    height: 1,
//                    color: Color(0xffd4d4d4),
//                  ),
//                  SizedBox(width: 48),
//                  Container(
//                    width: 64,
//                    height: 1,
//                    color: Color(0xffd4d4d4),
//                  ),
//                ],
//              ),
//            ),
//          ],
//        ),
        child: Image.asset(
          'assets/booking_header.png',
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

  Widget _buildNextStep(String number, String title) {
    return Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                  color: Color(0xffd4d4d4),
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Color(0xffd4d4d4)),
            color: Color(0xfff9f9f9),
          ),
          height: 50,
          width: 50,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: TextStyle(
              color: Color(0xffd4d4d4),
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildRoomTitle(int index) {
    int number = index + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          children: [
            Text(
              "غرفة رقم",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
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
          ],
        ),

        // Expanded(
        //   child: Container(),
        // ),
        Row(
          children: [
            index != 0
                ? GestureDetector(
                    child: Align(
                      child: Image.asset('assets/grey_close_ic.png'),
                      alignment: Alignment.centerLeft,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRoomsList.removeAt(index);
                        expansionTiles.removeAt(index);
                      });
                    },
                  )
                : SizedBox(),
            SizedBox(
              width: 5,
            ),
            index != 0
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
                        _selectedRoomsList.removeAt(index);
                        expansionTiles.removeAt(index);
                      });
                    },
                  )
                : SizedBox(),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomsList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedRoomsList.length,
        itemBuilder: (context, i) {
          return new Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTileTheme(
                  contentPadding: EdgeInsets.all(0),
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 15,
                  child: new AppExpansionTile(
                    key: expansionTiles[i],
                    backgroundColor: Colors.white,
//                  trailing: Icon(Icons.arrow_downward),
                    title: Container(
                      width: MediaQuery.of(context).size.width,
                      child: _buildRoomTitle(i),
                      color: Colors.white,
                    ),

                    initiallyExpanded: true,
                    onExpansionChanged: (bool value) {},
                    trailing: SizedBox(),
                    leading: SizedBox(),
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          _buildRoomContent(i),
                        ],
                      ),
                    ],
                  ),
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

  Widget _buildRoomContent(int index) {
    return Container(
      color: Colors.white,
//      height: 300,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20, top: 10, bottom: 5),
                    child: Text(
                      'نوع الغرفة',
                      style: TextStyle(
                        color: Color(0xff696969),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildRoomTypeDropDown(index),
                ],
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: <Widget>[
              //     Padding(
              //       padding: EdgeInsets.only(right: 20, top: 10, bottom: 5),
              //       child: Text(
              //         'عدد الافراد بالغرفة',
              //         style: TextStyle(
              //           color: Color(0xff696969),
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700,
              //         ),
              //       ),
              //     ),
              //     _buildRoomCapacityDropDown(index),
              //   ],
              // ),
            ],
          ),
          _selectedRoomsList[index].name == null
              ? SizedBox()
              : Align(
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 5, bottom: 5),
                    child: Text(
                      'سعة الغرفة ${_selectedRoomsList[index].capacity} أفراد ',
                      style: TextStyle(
                        color: Color(0xff696969),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  alignment: Alignment.centerRight,
                ),
          // Align(
          //   child: Padding(
          //     padding: EdgeInsets.only(right: 20, top: 20, bottom: 5),
          //     child: Text(
          //       'واجهة الغرفة',
          //       style: TextStyle(
          //         color: Color(0xff696969),
          //         fontSize: 15,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          //   alignment: Alignment.centerRight,
          // ),
          _buildRoomViewDropDown(index),
          _buildGuestNumberDropDown(index),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  _buildGuestNumberDropDown(index) {
    int assignedGuests = 0;
    int remainGuests = 0;
    _selectedRoomsList.forEach((element) {
      if (element.isContainGuests ?? false) {
        assignedGuests = (element.guestCount ?? 0) + assignedGuests;
      }
    });
    remainGuests = _trip.number_guest - assignedGuests;
    return (remainGuests == 0 &&
            (_selectedRoomsList[index].guestCount ?? 0) == 0)
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (_selectedRoomsList[index].isContainGuests ?? false)
                  ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Text(
                        "سعر الضيف فى الغرفة ${_selectedRoomsList[index].selectedRoomView?.room_guest_price ?? 0} جنيه ",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                  )
                  : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Checkbox(
                    onChanged: (value) {
                      _selectedRoomsList[index].isContainGuests =
                          value ?? false;
                      if (value == false) {
                        _selectedRoomsList[index].guestCount = 0;
                      }
                      setState(() {});
                    },
                    value: _selectedRoomsList[index].isContainGuests ?? false,
                  ),
                  Text(
                    'هل تحتوي ضيوف؟',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              (_selectedRoomsList[index].isContainGuests ?? false)
                  ? Row(
                      children: [
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              int num =
                                  _selectedRoomsList[index].guestCount ?? 0;
                              if (num < _trip.number_guest &&
                                  num <
                                      (_selectedRoomsList[index].capacity ??
                                          0) &&
                                  num <= remainGuests)
                                _selectedRoomsList[index].guestCount =
                                    num + 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.mediumGreen,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.add,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                              _selectedRoomsList[index].guestCount.toString()),
                        ),
                        InkWell(
                          onTap: () {
                            int num =
                                _selectedRoomsList[index].guestCount ?? 0;
                            if (num > 0) {
                              _selectedRoomsList[index].guestCount = num - 1;
                            }
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.mediumGreen,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.remove,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  List<TextEditingController> roomGuestNumber = [];

  Widget _buildChildrenTitle() {
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
              child: _hasChild
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
                  _hasChild = !_hasChild;

                  if (_hasChild) {
                    _addChild();
                  } else {
                    _selectedSeatsList.clear();
                    _childNameController.clear();
                    _seatsTypesDropdownItems.clear();
                  }
                });
              },
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'اطفال',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              child: Image.asset(
                _hasChild ? 'assets/add_ic_ac.png' : 'assets/add_ic_nr.png',
                width: 22,
                height: 22,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => _addChild(),
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              child: Text(
                'اضف سرير لطفل',
                style: TextStyle(
                    color: _hasChild ? Color(0xff43a047) : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              onTap: () => _addChild(),
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

  bool hasGuest = false;

  Widget _buildGuestTitle() {
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
              child: hasGuest
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
                  hasGuest = !hasGuest;
                });
                if (hasGuest && expansionGuestTiles.length == 0) {
                  if (expansionGuestTiles.length < _trip.number_guest) {
                    bool isGuestDataCompleted = false;
                    for (int i = 0; i < expansionGuestTiles.length; i++) {
                      if (_nameController[i].value.text.isEmpty) {
                        isGuestDataCompleted = false;
                        Fluttertoast.showToast(
                            msg: "برجاء إدخال الاسم",
                            toastLength: Toast.LENGTH_LONG);
                      } else if (_idNumberController[i].value.text.isEmpty) {
                        isGuestDataCompleted = false;
                        Fluttertoast.showToast(
                            msg: "برجاء إدخال الرقم القومي",
                            toastLength: Toast.LENGTH_LONG);
                      } else if (_birthDateController[i].value.text.isEmpty) {
                        isGuestDataCompleted = false;
                        Fluttertoast.showToast(
                            msg: "برجاء إدخال تاريخ الميلاد",
                            toastLength: Toast.LENGTH_LONG);
                      } else {
                        isGuestDataCompleted = true;
                      }
                    }
                    if (expansionGuestTiles.length == 0 ||
                        isGuestDataCompleted) {
                      expansionGuestTiles
                          .add(GlobalKey<AppExpansionTileState>());
                      _nameController.add(TextEditingController());
                      _idNumberController.add(TextEditingController());
                      _birthDateController.add(TextEditingController());
                    }
                    setState(() {});
                  }
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'ضيوف',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              child: Image.asset(
                (hasGuest && expansionGuestTiles.length < _trip.number_guest)
                    ? 'assets/add_ic_ac.png'
                    : 'assets/add_ic_nr.png',
                width: 22,
                height: 22,
                fit: BoxFit.fitWidth,
              ),
              onTap: () {
                if (expansionGuestTiles.length < _trip.number_guest) {
                  bool isGuestDataCompleted = false;
                  for (int i = 0; i < expansionGuestTiles.length; i++) {
                    if (_nameController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال الاسم",
                          toastLength: Toast.LENGTH_LONG);
                    } else if (_idNumberController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال الرقم القومي",
                          toastLength: Toast.LENGTH_LONG);
                    } else if (_birthDateController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال تاريخ الميلاد",
                          toastLength: Toast.LENGTH_LONG);
                    } else {
                      isGuestDataCompleted = true;
                    }
                  }
                  if (expansionGuestTiles.length == 0 || isGuestDataCompleted) {
                    expansionGuestTiles.add(GlobalKey<AppExpansionTileState>());
                    _nameController.add(TextEditingController());
                    _idNumberController.add(TextEditingController());
                    _birthDateController.add(TextEditingController());
                  }
                  setState(() {});
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              child: Text(
                'اضف ضيف اخر',
                style: TextStyle(
                    color: (hasGuest &&
                            expansionGuestTiles.length < _trip.number_guest)
                        ? Color(0xff43a047)
                        : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              onTap: () {
                if (expansionGuestTiles.length <= _trip.number_guest) {
                  bool isGuestDataCompleted = false;
                  for (int i = 0; i < expansionGuestTiles.length; i++) {
                    if (_nameController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال الاسم",
                          toastLength: Toast.LENGTH_LONG);
                    } else if (_nameController[i].value.text.length > 255) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال الاسم اقل من 255 حرف",
                          toastLength: Toast.LENGTH_LONG);
                    } else if (_idNumberController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال الرقم القومي",
                          toastLength: Toast.LENGTH_LONG);
                    } else if (_birthDateController[i].value.text.isEmpty) {
                      isGuestDataCompleted = false;
                      Fluttertoast.showToast(
                          msg: "برجاء إدخال تاريخ الميلاد",
                          toastLength: Toast.LENGTH_LONG);
                    } else {
                      isGuestDataCompleted = true;
                    }
                  }
                  if (expansionGuestTiles.length == 0 || isGuestDataCompleted) {
                    expansionGuestTiles.add(GlobalKey<AppExpansionTileState>());
                    _nameController.add(TextEditingController());
                    _idNumberController.add(TextEditingController());
                    _birthDateController.add(TextEditingController());
                  }
                  setState(() {});
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

  List<Guest> guestList = [];

  Widget _buildGuestList() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      color: Color(0xffeeeeee),
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expansionGuestTiles.length,
        itemBuilder: (context, i) {
          return new Container(
            color: Color(0xffeeeeee),
            child: Column(
              children: <Widget>[
                ListTileTheme(
                  contentPadding: EdgeInsets.all(0),
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 15,
                  child: new AppExpansionTile(
                    key: expansionGuestTiles[i],
                    backgroundColor: Color(0xffeeeeee),
                    // trailing: Icon(Icons.arrow_downward),
                    title: Container(
                      child: _buildGuestNoTitle(i),
                    ),
                    onExpansionChanged: (bool value) {},
                    trailing: SizedBox(),
                    leading: SizedBox(),
                    initiallyExpanded: true,
                    children: <Widget>[
                      Container(
                        color: Color(0xffeeeeee),
                        child: new Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(right: 15),
                                    width: 90,
                                    child: Text(
                                      "اسم",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    )),
                                _buildInputField("اسم", _nameController[i],
                                    TextInputType.text,
                                    onTap: () {})
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(right: 15),
                                    width: 90,
                                    child: Text(
                                      "رقم قومي ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    )),
                                _buildInputField(
                                    "رقم قومي",
                                    _idNumberController[i],
                                    TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[0-9]")),
                                    ],
                                    onTap: () {}),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(right: 15),
                                    width: 90,
                                    child: Text(
                                      "تاريخ ميلاد ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    )),
                                _buildInputField(
                                    "تاريخ ميلاد",
                                    _birthDateController[i],
                                    TextInputType.datetime,
                                    enable: false, onTap: () {
                                  _selectedDate(context, i);
                                })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  List<TextEditingController> _nameController = [];
  List<TextEditingController> _idNumberController = [];
  List<TextEditingController> _birthDateController = [];

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

  DateTime _date = DateTime.now();
  DateTime _dateNow = DateTime.now();

  Future<Null> _selectedDate(BuildContext context, int index) async {
    _date = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(1900),
        lastDate: _dateNow);

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _birthDateController[index].value =
            TextEditingValue(text: picked.toString().split(" ")[0]);
      });
    }
  }

  Widget _buildGuestNoTitle(int index) {
    int number = index + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "ضيف ",
          style: TextStyle(
              color: Color(0xff43a047),
              fontWeight: FontWeight.w700,
              fontSize: 17),
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
        index != 0
            ? GestureDetector(
                child: Align(
                  child: Container(
                    color: Color(0xffeeeeee),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 15),
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/grey_close_ic.png'),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'الغاء',
                          style: TextStyle(
                              color: Color(0xff212121),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onTap: () {
                  setState(() {
                    expansionGuestTiles.removeAt(index);
                    _nameController.removeAt(index);
                    _idNumberController.removeAt(index);
                    _birthDateController.removeAt(index);
                  });
                },
              )
            : SizedBox(),
        // SizedBox(
        //   width: 5,
        // ),
        // index != 0
        //     ? GestureDetector(
        //         child: Align(
        //           child: Text(
        //             'الغاء',
        //             style: TextStyle(
        //                 color: Color(0xff212121),
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w700),
        //           ),
        //           alignment: Alignment.centerLeft,
        //         ),
        //         onTap: () {
        //           setState(() {
        //             expansionGuestTiles.removeAt(index);
        //             _nameController.removeAt(index);
        //             _idNumberController.removeAt(index);
        //             _birthDateController.removeAt(index);
        //           });
        //         },
        //       )
        //     : SizedBox(),
      ],
    );
  }

  int selectedGuestNumbers = 1;

  Widget _buildChildrenList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedSeatsList.length,
        itemBuilder: (context, i) {
          return _buildChildItem(i);
        },
      ),
    );
  }

  List<TextEditingController> _childNameController = [];

  Widget _buildChildItem(int index) {
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
            height: 120,
            width: MediaQuery.of(context).size.width - 30,
            color: Color(0xffeeeeee),
            padding: EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5, top: 18),
                  child: Text(
                    'عمر طفل ' + (index + 1).toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.start,
                  ),
                ),
                _buildChildDropDown(index),
                _selectedSeatsList[index].name == null
                    ? SizedBox()
                    : Container(
                        child: Text(
                          "سعر سرير الطفل ${Validation.replaceArabicNumber(_selectedSeatsList[index].type_price.toString())}  جنيه مصري",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        margin: EdgeInsets.only(left: 10, right: 10),
                      ),
              ],
            ),
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
                          "اسم الطفل",
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
                                    _selectedSeatsList.removeAt(index);
                                    _childNameController.removeAt(index);
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
                                    _selectedSeatsList.removeAt(index);
                                    _childNameController.removeAt(index);
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
                    _buildInputField("اسم الطفل", _childNameController[index],
                        TextInputType.text,
                        inputFormatters: [
                          // FilteringTextInputFormatter.allow(filterPattern),
                        ],
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypeDropDown(int index) {
//    print("lenth drop down: " +
//        _roomTypesDropdownItems[index]
//            .where((DropdownMenuItem<TripRoomType> item) =>
//                item.value == _selectedRoomsList[index])
//            .length
//            .toString());
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 30;

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: new Text("نوع الغرفة"),
                  value: _selectedRoomsList[index].name == null
                      ? null
                      : _selectedRoomsList[index],
//                  value: _selectedRoomsList[index],
//                  value: TripRoomType(name: 'salma'),
                  items: _roomTypesDropdownItems[index],
//                    items: data.map((item) {
//                      return new DropdownMenuItem<String>(
//                        child: new Text(
//                          'Finca: ' + item['descripcion'],
//                        ),
//                        value: item['id'].toString(),
//                      );
//                    }).toList(),

                  onChanged: (TripRoomType? selectedRoomType) {
                    setState(() {
//                      selectedRoomType.selectedRoomView = null;
//                      selectedRoomType.selectedCapacity = null;
                      onChangeRoomTypeDropdownItem(
                          selectedRoomType ?? TripRoomType(), index);
                    });
                  },
                  icon: Image.asset('assets/dropdown_ic.png'),
                ),
              ),
            ),
            width: viewWidth,
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
      height: 50,
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 15, top: 5),
    );
  }

  Widget _buildRoomViewDropDown(int index) {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 30;
    return Container(
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      hint: new Text('واجهة الغرفة'),
                      value: _selectedRoomsList[index].selectedRoomView != null
                          ? _selectedRoomsList[index].selectedRoomView
                          : null,
                      items: _roomViewsDropdownItems[index],
//                    items: data.map((item) {
//                      return new DropdownMenuItem<String>(
//                        child: new Text(
//                          'Finca: ' + item['descripcion'],
//                        ),
//                        value: item['id'].toString(),
//                      );
//                    }).toList(),
                      onChanged: (AvailableRoomView? selectedRoomView) {
                        onChangeRoomViewDropdownItem(
                            selectedRoomView ?? AvailableRoomView(), index);
                      },
                      icon: Image.asset('assets/dropdown_ic.png'),
                    ),
                  ),
                ),
                width: viewWidth,
              ),
            ],
          ),
          _selectedRoomsList[index].name == null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.25),
                  ),
                  width: viewWidth + 30,
                  height: 50,
                )
              : SizedBox(),
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
      height: 50,
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 15, top: 5),
    );
  }

  Widget _buildRoomCapacityDropDown(int index) {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width / 2 - 30;
    return Container(
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      hint: new Text("عدد الافراد"),
                      value: _selectedRoomsList[index].selectedCapacity != null
                          ? _selectedRoomsList[index].selectedCapacity
                          : null,
                      items: _roomCapacityDropdownItems[index],
//                    items: data.map((item) {
//                      return new DropdownMenuItem<String>(
//                        child: new Text(
//                          'Finca: ' + item['descripcion'],
//                        ),
//                        value: item['id'].toString(),
//                      );
//                    }).toList(),

                      onChanged: (int? selectedRoomCapacity) {
                        onChangeRoomCapacityDropdownItem(
                            selectedRoomCapacity ?? 0, index);
                      },

                      icon: Image.asset('assets/dropdown_ic.png'),
                    ),
                  ),
                ),
                width: viewWidth,
              ),
            ],
          ),
          _selectedRoomsList[index].name == null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.25),
                  ),
                  width: viewWidth,
                  height: 50,
                )
              : SizedBox(),
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
      height: 50,
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 15, top: 5),
    );
  }

  Widget _buildChildDropDown(int index) {
    // double width = MediaQuery.of(context).size.width - 150;
    double width = MediaQuery.of(context).size.width / 1.2;
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                        hint: new Text(
                          'عمر طفل ' + (index + 1).toString(),
                        ),
                        value: _selectedSeatsList[index].name == null
                            ? null
                            : _selectedSeatsList[index],
                        items: _seatsTypesDropdownItems[index],
                        onChanged: (SeatType? selectedSeatType) {
                          onChangeSeatTypeDropdownItem(
                              selectedSeatType ?? SeatType(), index);
                        },
                        // isExpanded: false,
                        // icon: Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        icon: Image.asset('assets/dropdown_ic.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            width: width,
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

  List<DropdownMenuItem<TripRoomType>> buildRoomTypesDropdownMenuItems(
      List roomTypes) {
    print("screenWidth: " + screenWidth.toString());
    double viewWidth = screenWidth / 2 - 80;
    List<DropdownMenuItem<TripRoomType>> items = [];
    for (TripRoomType roomType in roomTypes) {
      items.add(
        DropdownMenuItem(
          value: roomType,
          child: Align(
            child: Container(
//              child: Center(
              child: Text(
                roomType.name ?? "",
                textAlign: TextAlign.right,
              ),

//              ),
              width: 200,
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<AvailableRoomView>> buildRoomViewsDropdownMenuItems(
      List roomViews) {
    List<DropdownMenuItem<AvailableRoomView>> items = [];
    for (AvailableRoomView roomView in roomViews) {
      items.add(
        DropdownMenuItem(
          value: roomView,
          child: Align(
            child: Container(
//              child: Center(
              child: Text(
                roomView.name ?? "",
                textAlign: TextAlign.right,
              ),
//              ),
              width: 200,
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> buildRoomCapacityDropdownMenuItems(
      List roomCapacity) {
    List<DropdownMenuItem<int>> items = [];
    for (int capacity in roomCapacity) {
      items.add(
        DropdownMenuItem(
          value: capacity,
          child: Align(
            child: Container(
//              child: Center(
              child: Text(
                capacity.toString(),
                textAlign: TextAlign.right,
              ),

//              ),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<SeatType>> buildSeatTypesDropdownMenuItems(
      List seatTypes) {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 90;

    List<DropdownMenuItem<SeatType>> items = [];
    for (SeatType seatType in seatTypes) {
      items.add(
        DropdownMenuItem(
          value: seatType,
          child: Align(
            child: Container(
              child: Text(
                seatType.name ?? "",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12),
                // maxLines: 1,
                // overflow: TextOverflow.ellipsis,
              ),
              width: viewWidth,
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }

    return items;
  }

  onChangeRoomTypeDropdownItem(TripRoomType selectedRoomType, int index) {
    setState(() {
//      TripRoomType newRoom = TripRoomType();
//      newRoom.id = selectedRoomType.id;
//      newRoom.name = selectedRoomType.name;
//      newRoom.capacity = selectedRoomType.capacity;
//      newRoom.available_room_views = selectedRoomType.available_room_views;
//      print("index of room list: " + index.toString());
//      TripRoomType roomType = TripRoomType(
//          id: selectedRoomType.id,
//          name: selectedRoomType.name,
//          capacity: selectedRoomType.capacity,
//          available_room_views: selectedRoomType.available_room_views);
      List<TripRoomType> values = [];
      values.addAll(_selectedRoomsList);
      _selectedRoomsList.clear();

      for (var i = 0; i < values.length; i++) {
        if (i == index) {
          selectedRoomType.selectedRoomView = null;
          selectedRoomType.selectedCapacity = null;
          selectedRoomType.guestCount = values[i].guestCount;
          selectedRoomType.isContainGuests = values[i].isContainGuests;
          _selectedRoomsList.add(selectedRoomType);
        } else {
          _selectedRoomsList.add(values[i]);
        }
      }

//      _selectedRoomsList[index] = selectedRoomType;
//      print(_selectedRoomsList[index].toString());
//      _selectedRoomsList[index].selectedRoomView = null;
//      _selectedRoomsList[index].selectedCapacity = null;
      if (selectedRoomType.available_room_views != null) {
        _roomViewsDropdownItems[index] = buildRoomViewsDropdownMenuItems(
            (selectedRoomType.available_room_views ?? []));
      }
      if (selectedRoomType.capacity != null) {
        List<int> capacity = new List<int>.generate(
            selectedRoomType.capacity ?? 0, (i) => i + 1);
        _roomCapacityDropdownItems[index] =
            buildRoomCapacityDropdownMenuItems(capacity);
      }
    });
  }

  onChangeRoomViewDropdownItem(AvailableRoomView selectedRoomView, int index) {
    setState(() {
      _selectedRoomsList[index].selectedRoomView = selectedRoomView;
      _selectedRoomsList[index].selectedCapacity =
          _selectedRoomsList[index].capacity;
    });
  }

  onChangeRoomCapacityDropdownItem(int selectedRoomCapacity, int index) {
    setState(() {
      _selectedRoomsList[index].selectedCapacity = selectedRoomCapacity;
    });
  }

  onChangeSeatTypeDropdownItem(SeatType selectedSeatType, int index) {
    setState(() {
      _selectedSeatsList[index] = selectedSeatType;
    });
  }

  bool _validateGuestData() {
    if (!hasGuest) return true;
    bool isGuestDataCompleted = false;
    guestList = [];
    for (int i = 0; i < expansionGuestTiles.length; i++) {
      if (_nameController[i].value.text.isEmpty) {
        isGuestDataCompleted = false;
        break;
      } else if (_idNumberController[i].value.text.isEmpty) {
        isGuestDataCompleted = false;
        break;
      } else if (_birthDateController[i].value.text.isEmpty) {
        isGuestDataCompleted = false;
        break;
      } else {
        isGuestDataCompleted = true;
      }
    }
    if (isGuestDataCompleted) {
      for (int i = 0; i < expansionGuestTiles.length; i++) {
        Guest guest = Guest(
          name: _nameController[i].value.text,
          nationalId: _idNumberController[i].value.text,
          birthdate: _birthDateController[i].value.text,
        );
        guestList.add(guest);
      }
    }
    return isGuestDataCompleted;
  }

  void _navigateToNextAction() {
    if (validateOtherMembers()) {
      if (_validateGuestData()) {
        if (_validateRoomsList()) {
          if (_validateGuestRoomsList()) {
            if (_selectedSeatsList.isNotEmpty) {
              _selectedSeatsList[_selectedSeatsList.length - 1].childName =
                  _childNameController[_selectedSeatsList.length - 1].text;
            }
            if (_validateChildrenList()) {
              print('Success Data');
              _trip.comment = _commentController.text;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EnterIDs(
                            this._trip,
                            this._bookingRequest,
                            this._selectedSeatsList,
                            this._selectedRoomsList,
                            // this._otherMembersList,
                            this.memberNameMap.keys.toList(),
                            hasGuest ? this.guestList : [],
                            this._reloadTripsDelagate,
                            this._isFromPushNotification,
                            this,
                          )));
            } else {
              Fluttertoast.showToast(
                  msg: 'برجاء إختيار عمر الطفل',
                  toastLength: Toast.LENGTH_LONG);
            }
          } else {
            Fluttertoast.showToast(
                msg: 'عدد الضيوف فالغرف يجب أن يساوي عدد الضيوف المضافة',
                toastLength: Toast.LENGTH_LONG);
          }
        } else {
          Fluttertoast.showToast(
              msg: 'برجاء استكمال بيانات الغرفة',
              toastLength: Toast.LENGTH_LONG);
        }
      } else {
        Fluttertoast.showToast(
            msg: 'برجاء استكمال بيانات الضيوف', toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'برجاء استكمال بيانات الاعضاء بشكل صحيح',
          toastLength: Toast.LENGTH_LONG);
    }
  }

  bool validateOtherMembers() {
    bool validOtherMember = true;
    if (this.memberNameMap.keys.isNotEmpty && hasOtherMembers) {
      validOtherMember = true;
    } else if (!hasOtherMembers) {
      validOtherMember = true;
    } else {
      validOtherMember = false;
    }
    return validOtherMember;
  }

  void _addChild() {
    setState(() {
      if (_hasChild) {
        _addNewSeatToList();
      }
    });
  }

  void _setRoomsList() {
    List<TripRoomType> list = [];
    if (_trip.formatted_room_types != null) {
      for (var i = 0; i < (_trip.formatted_room_types?.length ?? 0); i++) {
        TripRoomType tripRoomType1 = TripRoomType(
            id: _trip.formatted_room_types?[i].id,
            name: _trip.formatted_room_types?[i].name,
            capacity: _trip.formatted_room_types?[i].capacity,
            available_room_views:
                _trip.formatted_room_types?[i].available_room_views);
        list.add(tripRoomType1);
      }
    }

    _roomTypesDropdownItems[0] = buildRoomTypesDropdownMenuItems(list);
    expansionTiles.add(GlobalKey<AppExpansionTileState>());
  }

  void _addNewRoomToList() {
    if (_validateRoomsList()) {
      List<TripRoomType> list2 = [];
      for (var i = 0; i < (_trip.formatted_room_types?.length ?? 0); i++) {
        TripRoomType tripRoomType1 = TripRoomType(
            id: _trip.formatted_room_types?[i].id,
            name: _trip.formatted_room_types?[i].name,
            capacity: _trip.formatted_room_types?[i].capacity,
            available_room_views:
                _trip.formatted_room_types?[i].available_room_views);
        list2.add(tripRoomType1);
      }
      _roomTypesDropdownItems[_selectedRoomsList.length] =
          buildRoomTypesDropdownMenuItems(list2);
      _selectedRoomsList.add(TripRoomType());
      for (var i = 0; i < expansionTiles.length; i++) {
        expansionTiles[i].currentState?.collapse();
      }
      expansionTiles.add(GlobalKey<AppExpansionTileState>());
    } else {
      Fluttertoast.showToast(
          msg: 'برجاء استكمال بيانات الغرفة', toastLength: Toast.LENGTH_LONG);
    }
  }

  void _addNewSeatToList() {
    if (_selectedSeatsList.isNotEmpty) {
      _selectedSeatsList[_selectedSeatsList.length - 1].childName =
          _childNameController[_selectedSeatsList.length - 1].text;
    }
    if (_validateChildrenList()) {
      List<SeatType> list = [];
      for (var i = 0; i < (_trip.formatted_seat_types?.length ?? 0); i++) {
        SeatType seatType = SeatType(
          id: _trip.formatted_seat_types?[i].id,
          name: _trip.formatted_seat_types?[i].name,
          type_price: _trip.formatted_seat_types?[i].type_price,
        );
        list.add(seatType);
      }

      _seatsTypesDropdownItems[_selectedSeatsList.length] =
          buildSeatTypesDropdownMenuItems(list);
      _selectedSeatsList.add(SeatType());
      _childNameController.add(TextEditingController());
    } else {
      Fluttertoast.showToast(
          msg: 'برجاء إختيار عمر الطفل', toastLength: Toast.LENGTH_LONG);
    }
  }

  bool _validateRoomsList() {
    bool _isValid = true;
    for (TripRoomType tripRoomType in _selectedRoomsList) {
      // if (tripRoomType.selectedCapacity == null) {
      //   return false;
      // } else
      if ((tripRoomType.guestCount ?? 0) > (_trip.number_guest)) {}
      if (tripRoomType.selectedRoomView == null) {
        return false;
      }
    }
    return _isValid;
  }

  bool _validateGuestRoomsList() {
    bool _isValid = true;
    int assigneeGuestNum = 0;
    _selectedRoomsList.forEach((element) {
      assigneeGuestNum = (element.guestCount ?? 0) + assigneeGuestNum;
    });

    if ((assigneeGuestNum != guestList.length&&hasGuest)||(assigneeGuestNum>0&&!hasGuest)) {
      return false;
    }
    return _isValid;
  }

  bool _validateChildrenList() {
    bool _isValid = true;
    for (SeatType child in _selectedSeatsList) {
      if (child.name == null) {
        return false;
      }
    }
    return _isValid;
  }

  // List<String> _otherMembersList = [];
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
                              memberNameMap.length < _trip.number_non_followers)
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
                    memberNameMap.length < _trip.number_non_followers) {
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
  Map<String, String> memberNameMap = {};

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
                        // _bookingNetwork.getMemberNameById(value ?? "", this);
                      }
                    }),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(right: 15, top: 5, bottom: 5),
                  child: Text(
                    memberNameMap[_otherMembershipIdController[index].text] ??
                        "",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
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
            print('navigate to rooms');
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

  @override
  void extendTime(String time) {
    print('extendTime rooms number');
    setState(() {
      _bookingRequest.expired_at = time;
    });
  }

  @override
  void hideLoading() {
    // TODO: implement hideLoading
  }

  @override
  void showAuthError() {
    // TODO: implement showAuthError
  }

  @override
  void showGeneralError() {
    // TODO: implement showGeneralError
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void showNetworkError() {
    // TODO: implement showNetworkError
  }

  @override
  void showServerError(String? msg) {
    // TODO: implement showServerError
    Fluttertoast.showToast(msg: msg ?? "", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showSuccessCancel() {
    print("hgere sucess expire  ");
    // TODO: implement showSuccessCancel
  }

  @override
  void showSuccessCount(String? msg) {
    // TODO: implement showSuccessCount
  }

  @override
  void showSuccessWaiting() {
    // TODO: implement showSuccessWaiting
  }

  @override
  void showSuccess(BookingRequest? bookingRequest) {
    // TODO: implement showSuccess
  }

  @override
  void showSuccessMemberName(String? memberName, String MemberId) {
    print(memberName ?? "");
    memberNameMap[MemberId] = memberName ?? "";
    setState(() {});
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    required Key key,
    required this.leading,
    required this.title,
    required this.backgroundColor,
    required this.onExpansionChanged,
    this.children: const <Widget>[],
    required this.trailing,
    this.initiallyExpanded: false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Widget leading;
  final Widget title;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final Color backgroundColor;
  final Widget trailing;
  final bool initiallyExpanded;

  @override
  AppExpansionTileState createState() => new AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _easeOutAnimation;
  CurvedAnimation? _easeInAnimation;
  ColorTween? _borderColor;
  ColorTween? _headerColor;
  ColorTween? _iconColor;
  ColorTween? _backgroundColor;
  Animation<double>? _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        new CurvedAnimation(parent: _controller!, curve: Curves.easeOut);
    _easeInAnimation =
        new CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();
    _iconTurns =
        new Tween<double>(begin: 0.0, end: 0.5).animate(_easeInAnimation!);
    _backgroundColor = new ColorTween();

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller?.value = 1.0;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded)
          _controller?.forward();
        else
          _controller?.reverse();
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor =
        _borderColor?.evaluate(_easeOutAnimation!) ?? Colors.transparent;
    final Color? titleColor = _headerColor?.evaluate(_easeInAnimation!);

    return new Container(
      decoration: new BoxDecoration(
          color: _backgroundColor?.evaluate(_easeOutAnimation!) ??
              Colors.transparent,
          border: new Border(
            top: new BorderSide(color: borderSideColor),
            bottom: new BorderSide(color: borderSideColor),
          )),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data: new IconThemeData(
                color: _iconColor?.evaluate(_easeInAnimation!)),
            child: new ListTile(
                onTap: toggle,
                leading: widget.leading,
                title: new DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: titleColor),
                  child: widget.title,
                ),
                trailing: widget.trailing),
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _easeInAnimation?.value ?? 0,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor?.end = theme.dividerColor;
    _headerColor!
      ..begin = theme.textTheme.subtitle1!.color
      ..end = theme.accentColor;
    _iconColor!
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColor?.end = widget.backgroundColor;

    final bool closed = !_isExpanded && (_controller?.isDismissed ?? false);
    return new AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed ? null : new Column(children: widget.children),
    );
  }
}
