import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking.dart';
import 'package:sporting_club/data/model/user.dart';

import 'cancel_booking_button.dart';

class RealEstateUpcommingBookingView extends StatelessWidget {

  final UpcommingBooking upcommingBooking;
  final String upcommingBookingTitle;
  User user = User();

  final void Function() onCancelBooking;

  RealEstateUpcommingBookingView({
   required this.upcommingBooking,
    required this.onCancelBooking,
    required this.upcommingBookingTitle,
    required  this.user,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Padding(
            padding:  EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                   "مرحبا بالعضو:  ",
                  style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
                ),
                Text(
                  "${user.user_name}",
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(bottom: 20),
            child: Row(
              children: <Widget>[
                Text(
                  "رقم العضويه: ",
                  style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
                ),
                Text(
                  "${user.membership_no}",
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              upcommingBookingTitle,
              style: TextStyle(color: Color(0xff707070),fontSize: 14,fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding:  EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "رقم الحجز: ",
                  style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
                ),
                Text(
                  "${upcommingBooking.bookingCode}",
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "تاريخ المقابلة: ",
                  style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
                ),
                Text(
                  upcommingBooking.bookingDate??"",
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "موعد المقابلة: ",
                  style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
                ),
                Text(
                  upcommingBooking.bookingFrom??"",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "نوع العقد: ",
                style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  "${upcommingBooking.parentCategory} (${upcommingBooking.subCategory})",
                  style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(height: 50,),
          upcommingBooking.link != null ? RealEstateCancelBookingButton(onTap: onCancelBooking) : Container(),
        ],
      ),
    );
  }
}