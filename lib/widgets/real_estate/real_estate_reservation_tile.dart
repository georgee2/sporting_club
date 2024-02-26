import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/real_estate/booking.dart';

class RealEstateReservationTile extends StatelessWidget {

  final Booking booking;

  RealEstateReservationTile({
  required  this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            blurRadius: 8.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("حجز رقم ${booking.id}",style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.w700),),
              Text(booking.bookingDate??"",style: TextStyle(color: Color(0xff8E8E8E),fontWeight: FontWeight.w700,fontSize: 12),),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  "${booking.parentCategory != null ? "${booking.parentCategory}" : ""} ${booking.subCategory != null ? "(${booking.subCategory})" : ""}",
                  style: TextStyle(
                      color: Color(0xff38533E),
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
              SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text("${booking.bookingFrom}",// - ${booking.bookingTo}
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff373737),fontWeight: FontWeight.w700,fontSize: 12)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}