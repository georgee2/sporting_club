import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/utilities/app_colors.dart';


class EmergencyNoData extends StatelessWidget {
  final String message;
  final void Function() onTapNoData;

  const EmergencyNoData(
      {Key? key,
      required this.onTapNoData,
      this.message = "",
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/emergency_ic.png"),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "ليس لديك اقسام طوارئ",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }



}
