import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class EmergencyNoNetwork extends StatelessWidget {
  final String message;
  final void Function() onTapNoNetwork;

  const EmergencyNoNetwork({Key? key,required this.onTapNoNetwork,  this.message=""}) : super(key: key);

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
         SizedBox(height: 20,) ,
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "لا يوجد اتصال بالنت",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(onTap: (){
              onTapNoNetwork();
            },
              child: Text(
                "حاول مرة اخرى",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
