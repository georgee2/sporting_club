import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendInvoice extends StatefulWidget {
  SendInvoice();

  @override
  State<StatefulWidget> createState() {
    return SendInvoiceState();
  }
}

class SendInvoiceState extends State<SendInvoice> {
  final _controller = TextEditingController();

  SendInvoiceState();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Align(
                    child: IconButton(
                      icon: new Image.asset(
                        'assets/close_green_ic.png',
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Text(
                    'ارسال تفاصيل الحجز عن طريق البريد الاكتروني',
                    style: TextStyle(
                        color: Color(0xff43a047),
                        fontSize: 19,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Container(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: 'البريد الاكتروني',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      keyboardAppearance: Brightness.light,
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
                      color: Colors.white,
                    ),
                    height: 50,
                    margin: EdgeInsets.only(bottom: 5, top: 10),
                    padding: EdgeInsets.all(1),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: Container(
                        height: 55,
                        child: Center(
                          child: Text(
                            'ارسال',
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
                          color: Color(0xffff5c46),
                        ),
                      ),
                    ),
                    onTap: () => _sendEmailAction()),
                SizedBox(
                  height: 25,
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
              color: Colors.white,
            ),
            height: 320,
            width: width - 50,
          ),
        ),
      ),
    );
  }

  void _sendEmailAction() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    Validation _validation = Validation();
    if (_controller.text.isNotEmpty) {
      if (_validation.isEmail(_controller.text)) {
        final Email email = Email(
          body:
              'https://inducesmile.com/google-flutter/how-to-send-an-email-from-flutter-app/',
          subject: 'Email subject',
          recipients: [_controller.text],
//      attachmentPath: 'https://inducesmile.com/google-flutter/how-to-send-an-email-from-flutter-app/',
          isHTML: false,
        );
        await FlutterEmailSender.send(email);
        Navigator.pop(context);
      }else{
        Fluttertoast.showToast(msg:'يرجى إدخال بريد إلكتروني صحيح',
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }
}
