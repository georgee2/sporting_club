import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/ui/swvl/screens/swvl_details_screen.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class SwvlLineRow extends StatelessWidget {
  Rides rideItem;
  SwvlLineRow({required this.rideItem});

  @override
  Widget build(BuildContext context) {

    return  InkWell(
      onTap: () async {
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => SwvlDetailsScreen(
              suttleId: "1",
            ride: rideItem,
            )));
      },
      child: new Container(
        margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideItem.startDay??"",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:AppColors.silverColor),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          rideItem.startTime??"",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF5C46),
                            const Color(0xFFAC7A46),
                            const Color(0xFF43A047),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      rideItem.stationsData?.first.name??"",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),    Text(
                          rideItem.stationsData?.last.name??""
                          , style: TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                          fontWeight: FontWeight.normal
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),


                ]),
            SizedBox(
              height: 5,
            ),
            Text(
              (rideItem.busData?.make??"")+" "+ (rideItem.busData?.model??""),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.meduimGrey,
              ),
            ),

            Text(
              rideItem.busData?.plates??"",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.meduimGrey,
              ),
            ),

          ],
        ),
      ),
    );
  }

}
