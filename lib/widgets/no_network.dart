import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';

class NoNetwork extends StatelessWidget {

  NoNewrokDelagate _noNewrokDelagate;

  NoNetwork( this._noNewrokDelagate);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/wifi.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              'لا يوجد اتصال بالانترنت',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey),
            )
          ],
        ),
      ),
      onTap: () {
        if (_noNewrokDelagate != null) {
          _noNewrokDelagate.reloadAction();
        }
      },
    );
  }
}
