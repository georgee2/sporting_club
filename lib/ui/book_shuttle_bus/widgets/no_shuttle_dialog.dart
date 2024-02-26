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

class NoShuttleDialog extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return new Directionality(
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
                      "جارى إستخراج الموافقات اللازمة",
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
                              'حسنا',
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
                      onTap: (){
                        Navigator.pop(context);
                      }),
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
              height:  295,
              width: width - 50,
            ),
          ),
        ),
      ),
    );
  }


}


