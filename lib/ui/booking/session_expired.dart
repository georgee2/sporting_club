import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/booking_request_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/ui/booking/rooms_number.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SessionExpired extends StatefulWidget {
  bool _isFromPushNotification = false;
  Trip _trip = Trip();

  SessionExpired(this._trip, this._isFromPushNotification);

  @override
  State<StatefulWidget> createState() {
    return SessionExpiredState(this._trip, this._isFromPushNotification);
  }
}

class SessionExpiredState extends State<SessionExpired> {
  bool _isFromPushNotification = false;
  Trip _trip = Trip();

  SessionExpiredState(this._trip, this._isFromPushNotification);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: ()async {
        _navigateToTripDetailsAction();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.50),
        body: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.only(left: 10),
//                    child: Align(
//                      child: IconButton(
//                        icon: new Image.asset(
//                          'assets/close_green_ic.png',
//                          width: 30,
//                          height: 30,
//                        ),
////                      onPressed: () => Navigator.of(context).pop(null),
//                      ),
//                      alignment: Alignment.topLeft,
//                    ),
//                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'انتهى الوقت المتاح لك للحجز',
                    style: TextStyle(
                        color: Color(0xffdb6868),
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Text(
                      'لا يمكنك حجز هذه الرحلة حالياً يرجى العودة إلى الصفحة الرئيسية',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          height: 55,
                          child: Center(
                            child: Text(
                              'العودة لجميع الرحلات',
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
                      onTap: () => _navigateToTripsAction()),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    child: Text(
                      'تفاصيل الرحلة',
                      style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Color(0xff43a047)),
                    ),
                    onTap: () => _navigateToTripDetailsAction(),
                  ),
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
                color: Color(0xfffcf2f1),
              ),
              height: 295,
              width: width - 50,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTripsAction() {
    if (_isFromPushNotification) {
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: RouteSettings(name: 'TripsList'),
          builder: (context) => TripsList(_isFromPushNotification,true),
        ),
      );
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('TripsList'));
    }
  }

  void _navigateToTripDetailsAction() {
    if (_isFromPushNotification) {
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: RouteSettings(name: 'TripDetails'),
          builder: (context) =>
              TripDetails(_trip.id??0, null, _isFromPushNotification),
        ),
      );
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('TripDetails'));
    }
  }
}
