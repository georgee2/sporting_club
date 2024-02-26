import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class ShuttleSelectFooter extends StatelessWidget {
  final void Function() navigateToNextAction;
  ShuttleBookingData shuttleBookingData;

  ShuttleSelectFooter({
    required this.shuttleBookingData,
    required this.navigateToNextAction,
  });

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: Text(
                shuttleBookingData.message??"",
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
                      color: shuttleBookingData == null
                          ? Colors.grey
                          : Color(0xffff5c46),
                    ),
                  ),
                ),
                onTap: () {
                  if (shuttleBookingData != null) {
                    navigateToNextAction();
                  }
                }),
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
}
