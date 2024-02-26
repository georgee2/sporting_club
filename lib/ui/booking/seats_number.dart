import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/booking_request_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/ui/Update_membership/register_membership.dart';
import 'package:sporting_club/ui/booking/rooms_number.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SeatsNumber extends StatefulWidget {
  Trip _trip = Trip();
  bool _isWaitingList = false;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  int SeatsNumbers = 0;

  SeatsNumber(
      this._trip,
      this.SeatsNumbers,

      this._isWaitingList,
      this._reloadTripsDelagate,
      this._isFromPushNotification,
      );

  @override
  State<StatefulWidget> createState() {
    return SeatsNumberState(
      this._trip,
      this._isWaitingList,
      this.SeatsNumbers,

      this._reloadTripsDelagate,
      this._isFromPushNotification,
    );
  }
}

class SeatsNumberState extends State<SeatsNumber>
    implements SeatsNumberResponseListener {
  //final _controller = TextEditingController();
  bool _isloading = false;
  BookingNetwork _bookingNetwork = BookingNetwork();
  Trip _trip = Trip();
  bool _isWaitingList = false;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  List<DropdownMenuItem<int>> _childrenSeatsCapacityDropdownItems = [];
  int SeatsNumbers = 0;
  String seatVaue = "1";


  SeatsNumberState(
      this._trip,
      this._isWaitingList,
      this.SeatsNumbers,

      this._reloadTripsDelagate,
      this._isFromPushNotification,
      );

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // _controller.text = "1";

    return ModalProgressHUD(
      child:
      new Directionality(
        textDirection: TextDirection.rtl,
        child:Scaffold(
          backgroundColor: Colors.black.withOpacity(0.50),
          body: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Align(
                        child: IconButton(
                          icon: new Image.asset(
                            'assets/close_green_ic.png',
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () => Navigator.of(context).pop(null),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: Text(
                        _isWaitingList
                            ? "قم بإضافة عدد الافراد على قائمة الانتظار"
                            : 'قم بإضافة عدد الافراد',
                        style: TextStyle(
                            color: Color(0xff43a047),
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: Container(
                        child:  _buildChildrenSeatsDropDown(),
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
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: Container(
//                    width: 300,
                            height: 55,
                            child: Center(
                              child: Text(
                                'تأكيد العدد',
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
                        onTap: () => _setSeatsNumberAction()),
                    SizedBox(
                      height: 25,
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
                height: _isWaitingList ? 320 : 295,
                width: width - 50,
              ),
            ),
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
  // void _setSeatsNumberAction() {
  //   FocusScope.of(context).requestFocus(new FocusNode());
  //   print('setSeatsNumberAction');
  //   print("_controller.text: " + _controller.text);
  //   if (_controller.text.isNotEmpty && _controller.text != "0") {
  //     if (int.parse(_controller.text) > 0) {
  //       if (_isWaitingList) {
  //         _bookingNetwork.setWaitnigSeatsNumber(
  //             int.parse(_controller.text), _trip.id, this);
  //       } else {
  //         _bookingNetwork.setSeatsNumber(
  //             int.parse(_controller.text), _trip.id, this);
  //       }
  //     } else {
  //       Fluttertoast.showToast(msg:'يجب أن يبدأ عدد المقاعد من 1', context,
  //           duration: Toast.LENGTH_LONG);
  //     }
  //   } else {
  //     Fluttertoast.showToast(msg:'يجب أن يبدأ عدد المقاعد من 1', context,
  //         duration: Toast.LENGTH_LONG);
  //   }
  // }
  void _setSeatsNumberAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    print('setSeatsNumberAction');
    print("_controller.text: " + seatVaue);
    if (seatVaue.isNotEmpty && seatVaue != "0") {
      if (int.parse(seatVaue) > 0) {
        if (_isWaitingList) {
          _bookingNetwork.setWaitnigSeatsNumber(
              int.parse(seatVaue), _trip.id??0, this);
        } else {
          _bookingNetwork.setSeatsNumber(
              int.parse(seatVaue), _trip.id??0, this);
        }
      } else {
        Fluttertoast.showToast(msg:'يجب أن يبدأ عدد المقاعد من 1',
            toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(msg:'يجب أن يبدأ عدد المقاعد من 1',
          toastLength: Toast.LENGTH_LONG);
    }
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
  void showSuccess(BookingRequest? bookingRequest) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
            //    RegisterMembership(
            //  )));
            RoomsNumber(
              this._trip,
              bookingRequest ?? BookingRequest(),
              MediaQuery.of(context).size.width,
              _reloadTripsDelagate,
              this._isFromPushNotification,
            )));
  }

  @override
  void showSuccessWaiting() {
    Navigator.pop(context);
    Fluttertoast.showToast(msg:'سيتم التواصل معك في حال توافر أماكن متاحة بالرحلة', toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showSuccessCancel() {
    // TODO: implement showSuccessCancel
  }

  @override
  void showSuccessMemberName(String? memberName, String MemberId) {
    // TODO: implement showSuccess
  }
//  String replacedArabicDigitsWithEnglish(String str) {
//    Map<String, String> map = {"٠": "0", "١": "1",
//      "٢": "2",
//      "٣": "3",
//      "٤": "4",
//      "٥": "5",
//      "٦": "6",
//      "٧": "7",
//      "٨": "8",
//      "٩": "9",
//      "٫": ".",
//      ",": "."};
//    map.forEach {
//      str = str.replaceAll(of: $0, with: $1)
//    }
//    return str
//  }

  Widget _buildChildrenSeatsDropDown() {
    double width = MediaQuery.of(context).size.width;
    _childrenSeatsCapacityDropdownItems.clear();
    for (int index = 1; index <= SeatsNumbers ; index++) {
      _childrenSeatsCapacityDropdownItems.add(
        DropdownMenuItem(
          value: index,
          child: Align(
            child: Container(
//              child: Center(
              width: width-200,
              child: Text(
                index.toString(),
                textAlign: TextAlign.center,
              ),

//              ),
            ),
            alignment: Alignment.center,
          ),
        ),
      );
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // width: width-150,
            child: DropdownButtonHideUnderline(
              child: Center(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    hint: Center(child: new Text("1")),
                    value: int.parse(seatVaue)  ,
                    items: _childrenSeatsCapacityDropdownItems,
                    onChanged: (int? guestNumbers) {
                      setState(() {
                        seatVaue = guestNumbers.toString();
                        //seatnum = guestNumbers;
                      });
                    },
                    // isExpanded: false,
                    icon: Image.asset('assets/dropdown_ic.png'),
                  ),
                ),
              ),
            ),
//            width: 65,
          ),
        ],
      ),

      height: 40,
      margin: EdgeInsets.only(left: 5, bottom: 5, right: 5, top: 5),
    );
  }

  @override
  void showSuccessCount(String? count) {
    // TODO: implement showSuccessCount
  }

}
