import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class AppLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      // color: AppColors.lightGreen.withOpacity(0.1),
      child: Center(
    child: SizedBox(
      width: 50,
      height: 50,
      child:
      CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
        AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    ),
      ),
    );
  }
}
