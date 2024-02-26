import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/emergency.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class EmergencyNumbers extends StatelessWidget {

  Emergency emergency = Emergency();
  EmergencyNumbers(this.emergency);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              child: Image.asset(
                'assets/close_ic_1.png',
                width: 20,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            Text(
              'أرقام الطوارئ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            GestureDetector(
                child: Container(
                  width: 300,
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'اتصل بالعيادة',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        child: Image.asset(
                          'assets/clinic.png',
                          width: 20,
                          fit: BoxFit.fitWidth,
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
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
                    color: Color(0xff43A047),
                  ),
                ),
                onTap: _callClinic),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              child: Container(
                width: 300,
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'اتصل بالأمن',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Align(
                      child: Image.asset(
                        'assets/police.png',
                        width: 20,
                        fit: BoxFit.fitWidth,
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
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
                  color: Color(0xff00701A),
                ),
              ),
              onTap: _callSecurity,
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
                child: Container(
                  width: 300,
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'اتصل بجولف كار',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        child: Image.asset(
                          'assets/golf_car_ic.png',
                          width: 20,
                          fit: BoxFit.fitWidth,
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
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
                    color: Color(0xffFF5C46),
                  ),
                ),
                onTap: _callGolCar),

          ],
        ),
      ),
    );
  }

  void _callClinic() {
    if(emergency.clinic != null){
      UrlLauncher.launch("tel:${emergency.clinic}");
    }
  }

  void _callSecurity() {
    if(emergency.security != null){
      UrlLauncher.launch("tel:${emergency.security}");
    }  }

  void _callGolCar() {
    if(emergency.golfCar != null){
      UrlLauncher.launch("tel:${emergency.golfCar}");
    }
  }
}
