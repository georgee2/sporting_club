import 'package:flutter/material.dart';

class SuccessMessageView extends StatelessWidget {

  final String message;

  SuccessMessageView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/going_ac.png",
            height: 110,
            width: 100,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              message,
              style: TextStyle(color: Color(0xff57A95A),fontWeight: FontWeight.bold,fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}