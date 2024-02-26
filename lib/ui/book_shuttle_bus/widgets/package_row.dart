import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class ShuttlePackageRow extends StatelessWidget {
  final void Function() onTapAction;
   ShuttlePackage shuttlePackage;
   bool isSelectedPackage;
  ShuttlePackageRow({Key? key, required this .shuttlePackage, required this.onTapAction,this.isSelectedPackage=false }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapAction();
      },
      child: new Container(
          margin:
          EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Radio(
                    groupValue: true,
                    value:isSelectedPackage,
                    onChanged: (val) {
                      onTapAction();
                    },
                  ),
                  Text(
                    shuttlePackage.name??"",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              Row(children: <Widget>[
                Text(
                  "سعر الفرد",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  " ${shuttlePackage.price} ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  "جنيه",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
              ]),
            ],
          )),
    );
  }
}
