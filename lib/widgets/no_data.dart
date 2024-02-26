import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  String _title = "";

  NoData(this._title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/eye-close-line.png'),
          SizedBox(
            height: 10,
          ),
          Text(
            _title,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
