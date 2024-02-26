import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/events/event_details.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/offers_services/offer_service_details.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/ui/update_info/update_info_firstStep.dart';
import 'package:sporting_club/ui/update_info/update_info_secondStep.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui' as ui;

class VerifyLogin extends StatefulWidget {
  String _userMembership = "";
  String? successMsg = "";
  bool send_phone;
  bool send_email;
  final String? type;
  final String? postId;
  final bool? from_branch;

  VerifyLogin(
      this._userMembership, this.successMsg, this.send_phone, this.send_email,
      {this.type, this.postId, this.from_branch});

  @override
  State<StatefulWidget> createState() {
    return VerifyLoginState(this._userMembership);
  }
}

class VerifyLoginState extends State<VerifyLogin>
    implements LoginResponseListener, BasicResponseListener {
  final _firstFocus = FocusNode();
  final _secondFocus = FocusNode();
  final _thirdFocus = FocusNode();
  final _forthFocus = FocusNode();

  final _firstController = TextEditingController();
  final _secondController = TextEditingController();
  final _thirdController = TextEditingController();
  final _forthController = TextEditingController();
  final _controller = TextEditingController();

  String _firstValue = "";
  String _secondValue = "";
  String _thirdValue = "";
  String _forthValue = "";

  String _code = "";
  String _verifyButtonImage = "assets/verified_btn_nr.png";
  bool _isloading = false;
  UserNetwork userNetwork = UserNetwork();
  String _userMembership = "";
  LocalSettings _localSettings = LocalSettings();
  Timer? timer;
  String _timerValue = "";

  // var timerofcount = 120;
  int remainsDuration = 120;

  VerifyLoginState(this._userMembership);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FlutterClipboard.paste().then((value) {
    //   // Do what ever you want with the value.
    //   if (value.length == 4) {
    //     _firstController.text = value.split("")[0];
    //     _secondController.text = value.split("")[1];
    //     _thirdController.text = value.split("")[2];
    //     _forthController.text = value.split("")[3];
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
//    _firstController.text = _firstValue;
//    _secondController.text = _secondValue;
//    _thirdController.text = _thirdValue;
//    _forthController.text = _forthValue;
//
//    var cursorPos = _firstController.selection;
//
//    if (cursorPos.start > _firstController.text.length) {
//      cursorPos = new TextSelection.fromPosition(
//          new TextPosition(offset: _firstController.text.length));
//    }
//    _firstController.selection = cursorPos;
    if (timer != null) {
      timer?.cancel();
    }
    _setTimer();
    return ModalProgressHUD(
//      child: Directionality(
//        textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Container(
            color: Color(0xff43a047),
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff43a047), Color(0xff00701a)])),
          ),
          Scaffold(
            backgroundColor: Color(0xff43a047),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // <-- APPBAR WITH TRANSPARENT BG
              elevation: 0,
              actions: <Widget>[
                new IconButton(
                  icon: new Image.asset('assets/back_grey.png'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
              leading: new Container(),
              // <-- ELEVATION ZEROED
              automaticallyImplyLeading:
                  true, // Used for removing back buttoon.
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(right: 25, left: 25),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
//      ),
      inAsyncCall: _isloading,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }

  Widget _buildContent() {
//    var re = RegExp(r'\d{8}'); // replace two digits
//    var hshNumer = LocalSettings.user.phone.replaceFirst(re, '********');
    double width =( (MediaQuery.of(context).size.width) / 4 ) - 70;

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
//      mainAxisAlignment: MainAxisAlignment.center,
//      crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image.asset(
              'assets/sporting_logo.png',
              fit: BoxFit.fitWidth,
              height: 120,
              width: 120,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              'كود التفعيل',
              style: TextStyle(
                fontSize: 26,
                color: Color(0xff76d275),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
//          Center(
//            child: Text(
//              'الرجاء ادخال رمز التحقق المرسل الى رقم الهاتف',
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                fontSize: 16,
//                color: Colors.white,
//              ),
//            ),
//          ),
          Center(
            child: Text(
              widget.successMsg??"",
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 35,
          ),
          // PinEntryTextField(
          //   fields: 4,
          //   onSubmit: (text) {
          //   },
          //
          // ),
          // PinCodeTextField(
          //   length: 6,
          //   obsecureText: false,
          //   animationType: AnimationType.fade,
          //   animationDuration: Duration(milliseconds: 300),
          // //  errorAnimationController: errorController, // Pass it here
          //   onChanged: (value) {
          //     setState(() {
          //       _code = value;
          //     });
          //   },
          // )
       //  ,

    Container(
      child:IntrinsicWidth(child:
       TextField(
              controller: _controller,
              textAlign: TextAlign.left,

              style: TextStyle(
                letterSpacing: 38,
                fontSize: 20.0,
                color: Colors.white
              ),
         cursorColor: Color(0xff76d275) ,
              autofocus: true,
    onChanged: (value) {
      _checknewCodeValidations();

    },
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,

                contentPadding:
                  EdgeInsets.only(left: 20, bottom: 0, top: 11, right: 20),
                hintText: '----',
                  hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275) ,letterSpacing: 38),
                  counterText: ''

              ),
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.light,
              maxLength: 4,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
    ),

            decoration: new BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.transparent),
              borderRadius: new BorderRadius.all(Radius.circular(0)),
            ),
            height: 50,
            // width :
            margin: EdgeInsets.only(bottom: 5, top: 10,left: 32,right: 32),
            padding: EdgeInsets.all(1),


    )

          ,
          //

   _buildVerificationCode(),
          SizedBox(
            height: 80,
          ),
          _buildSubmitButton(),
          Visibility(
            child: Text(
              _timerValue,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            visible: _timerValue != "00:00:00",
          ),
          Visibility(
            child: GestureDetector(
              child: Text(
                "إعادة إرسال كود التفعيل",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decorationThickness: 2,
                    decoration: TextDecoration.underline),
              ),
              onTap: () {
                print("here");
                // userNetwork.loginUser(_userMembership, this);
                userNetwork.loginUser(_userMembership, widget.send_phone,
                    widget.send_email, this);

//    userNetwork.registerPayment(
//    _userMembership, _email, _phone,
//    this);
              },
            ),
            visible: _timerValue == "00:00:00",
          ),
          SizedBox(
            height: 10,
          ),
          _buildErrorContent()
        ],
      ),
    );
  }
 
  Widget _buildVerificationCode() {
    return
      Column(
        children: <Widget>[

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildInputField(
                  _firstController, _firstFocus, _secondFocus, _firstFocus),
              SizedBox(
                width: 10,
              ),
              _buildInputField(
                  _secondController, _secondFocus, _thirdFocus, _firstFocus),
              SizedBox(
                width: 10,
              ),
              _buildInputField(
                  _thirdController, _thirdFocus, _forthFocus, _secondFocus),
              SizedBox(
                width: 10,
              ),
              _buildInputField(
                  _forthController, _forthFocus, _forthFocus, _thirdFocus),

//        _buildRTLInputField(
//            _firstController, _firstFocus, _secondFocus, _firstFocus),
//        SizedBox(
//          width: 10,
//        ),
//        _buildSecondRTLInputField(
//            _secondController, _secondFocus, _thirdFocus, _firstFocus),
//        SizedBox(
//          width: 10,
//        ),
//        _buildThirdRTLInputField(
//            _thirdController, _thirdFocus, _forthFocus, _secondFocus),
//        SizedBox(
//          width: 10,
//        ),
//        _buildForthRTLInputField(
//            _forthController, _forthFocus, _forthFocus, _thirdFocus),
            ],
          )
        ],
      );
  }

  Widget _buildInputField(
      TextEditingController controller,
      FocusNode currentFocusNode,
      FocusNode nextFocusNode,
      FocusNode previousFocusNode) {
    return Column(
      children: <Widget>[
//         Container(
//           child: TextField(
//             focusNode: currentFocusNode,
//             controller: controller,
//             textAlign: TextAlign.center,
//             decoration: new InputDecoration(
// //              enabledBorder: UnderlineInputBorder(
// //                  borderSide: BorderSide(color: Color(0xff76d275))),
// //              focusedBorder: UnderlineInputBorder(
// //                borderSide: BorderSide(color: Colors.white),
// //              ),
//
//               enabledBorder: InputBorder.none,
//               focusedBorder: InputBorder.none,
//               contentPadding:
//                   EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
//               hintText: '-',
//               hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275)),
//             ),
//             style: TextStyle(color: Color(0xff76d275), fontSize: 30),
//             keyboardType: TextInputType.number,
//             keyboardAppearance: Brightness.light,
//             autofocus: true,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(1),
//             ],
//             onChanged: (value) {
//               _checkCodeValidations();
//               setState(() {
//                 controller.text = value;
//               });
//               print('onChanged');
//               if (value != "") {
//                 if (currentFocusNode == _forthFocus) {
//                   if (value.length == 1) {
//                     FocusScope.of(context).requestFocus(new FocusNode());
//                   }
//                 } else {
//                   FocusScope.of(context).requestFocus(nextFocusNode);
//                 }
//               } else {
//                 FocusScope.of(context).requestFocus(previousFocusNode);
//               }
//             },
//           ),
//           width: 55,
//         ),
        Container(
          height: 2,
          width: 35,
          color: _controller.text.length < 4 ? Color(0xff76d275) : Colors.white,
          padding: EdgeInsets.all(1),
        )
      ],
    );
  }

  Widget _buildErrorContent() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'اذا تم تغيير رقم الهاتف/البريد الالكتروني',
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UpdateInfoFirstStep(widget._userMembership)));
            },
            child: Text(
              'يرجى تحديث المعلومات',
              style: TextStyle(
                  color: Color(0xfff12b10),
                  fontSize: 15,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 8, top: 8),
      margin: EdgeInsets.only(bottom: 20, top: 10),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildRTLInputField(
      TextEditingController controller,
      FocusNode currentFocusNode,
      FocusNode nextFocusNode,
      FocusNode previousFocusNode) {
    return Column(
      children: <Widget>[
        Container(
          child: TextField(
            focusNode: currentFocusNode,
            controller: controller,
            textAlign: TextAlign.center,
            decoration: new InputDecoration(
//              enabledBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Color(0xff76d275))),
//              focusedBorder: UnderlineInputBorder(
//                borderSide: BorderSide(color: Colors.white),
//              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: '-',
              hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275)),
            ),
            style: TextStyle(color: Color(0xff76d275), fontSize: 30),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
//              _checkCodeValidations();
              setState(() {
                if (value == "") {
                  if (_firstValue.isEmpty) {
                    if (_secondValue.isNotEmpty) {
                      _secondValue = _thirdValue;
                      _thirdValue = _forthValue;
                      _forthValue = "";
//                  } else if (_thirdValue.isNotEmpty) {
//                    _thirdValue = "";
//                  } else if (_forthValue.isNotEmpty) {
//                    _forthValue = "";

                    } else {}
                  } else {
                    _firstValue = _secondValue;
                    _secondValue = _thirdValue;
                    _thirdValue = _forthValue;
                    _forthValue = "";
                  }
                } else {
                  if (_forthValue.isNotEmpty &&
                      _thirdValue.isNotEmpty &&
                      _secondValue.isNotEmpty) {
                    _firstValue = value;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  } else {
                    _forthValue = _thirdValue;
                    _thirdValue = _secondValue;
                    _secondValue = value;
                  }
                }
              });
              print('onChanged');
//              if (value != "") {
//                if (currentFocusNode == _forthFocus) {
//                  if (value.length == 1) {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                  }
//                } else {
//                  FocusScope.of(context).requestFocus(nextFocusNode);
//                }
//              } else {
//                FocusScope.of(context).requestFocus(previousFocusNode);
//              }
//              FocusScope.of(context).requestFocus(currentFocusNode);
            },
          ),
          width: 55,
        ),
        Container(
          height: 2,
          width: 45,
          color: controller.text.isEmpty ? Color(0xff76d275) : Colors.white,
          padding: EdgeInsets.all(1),
        )
      ],
    );
  }

  Widget _buildSecondRTLInputField(
      TextEditingController controller,
      FocusNode currentFocusNode,
      FocusNode nextFocusNode,
      FocusNode previousFocusNode) {
    return Column(
      children: <Widget>[
        Container(
          child: TextField(
            focusNode: currentFocusNode,
            controller: controller,
            textAlign: TextAlign.center,
            decoration: new InputDecoration(
//              enabledBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Color(0xff76d275))),
//              focusedBorder: UnderlineInputBorder(
//                borderSide: BorderSide(color: Colors.white),
//              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: '-',
              hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275)),
            ),
            style: TextStyle(color: Color(0xff76d275), fontSize: 30),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
//              _checkCodeValidations();
              setState(() {
//                _thirdController.text = value;
//                _forthController.text = _thirdController.text;
//                _firstController.text = "";
//                _secondController.text = value;
//                _firstController.text = "";
//                print("all code: "+_code);
//                print("first code: "+_code[0]);
//
//                if (_code.length == 1) {
//                  _secondController.text = value;
//                  _firstController.text = "";
//                } else if (_code.length == 2) {
//                  print("second code: "+_code[1]);
//                  _thirdController.text = _code[1];
//                  _secondController.text = _code[0];
//                  _firstController.text = "";
//                }
              });
              print('onChanged');
//              if (value != "") {
//                if (currentFocusNode == _forthFocus) {
//                  if (value.length == 1) {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                  }
//                } else {
//                  FocusScope.of(context).requestFocus(nextFocusNode);
//                }
//              } else {
//                FocusScope.of(context).requestFocus(previousFocusNode);
//              }
//              FocusScope.of(context).requestFocus(currentFocusNode);
            },
          ),
          width: 55,
        ),
        Container(
          height: 2,
          width: 45,
          color: controller.text.isEmpty ? Color(0xff76d275) : Colors.white,
          padding: EdgeInsets.all(1),
        )
      ],
    );
  }

  Widget _buildThirdRTLInputField(
      TextEditingController controller,
      FocusNode currentFocusNode,
      FocusNode nextFocusNode,
      FocusNode previousFocusNode) {
    return Column(
      children: <Widget>[
        Container(
          child: TextField(
            focusNode: currentFocusNode,
            controller: controller,
            textAlign: TextAlign.center,
            decoration: new InputDecoration(
//              enabledBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Color(0xff76d275))),
//              focusedBorder: UnderlineInputBorder(
//                borderSide: BorderSide(color: Colors.white),
//              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: '-',
              hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275)),
            ),
            style: TextStyle(color: Color(0xff76d275), fontSize: 30),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
//              _checkCodeValidations();

              setState(() {
                _forthController.text = value;

//                _forthController.text = _thirdController.text;
//                _firstController.text = "";
//                _secondController.text = value;
//                _firstController.text = "";
//                print("all code: "+_code);
//                print("first code: "+_code[0]);
//
//                if (_code.length == 1) {
//                  _secondController.text = value;
//                  _firstController.text = "";
//                } else if (_code.length == 2) {
//                  print("second code: "+_code[1]);
//                  _thirdController.text = _code[1];
//                  _secondController.text = _code[0];
//                  _firstController.text = "";
//                }
              });
              print('onChanged');
//              if (value != "") {
//                if (currentFocusNode == _forthFocus) {
//                  if (value.length == 1) {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                  }
//                } else {
//                  FocusScope.of(context).requestFocus(nextFocusNode);
//                }
//              } else {
//                FocusScope.of(context).requestFocus(previousFocusNode);
//              }
//              FocusScope.of(context).requestFocus(currentFocusNode);
            },
          ),
          width: 55,
        ),
        Container(
          height: 2,
          width: 45,
          color: controller.text.isEmpty ? Color(0xff76d275) : Colors.white,
          padding: EdgeInsets.all(1),
        )
      ],
    );
  }

  Widget _buildForthRTLInputField(
      TextEditingController controller,
      FocusNode currentFocusNode,
      FocusNode nextFocusNode,
      FocusNode previousFocusNode) {
    return Column(
      children: <Widget>[
        Container(
          child: TextField(
            focusNode: currentFocusNode,
            controller: controller,
            textAlign: TextAlign.center,
            decoration: new InputDecoration(
//              enabledBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Color(0xff76d275))),
//              focusedBorder: UnderlineInputBorder(
//                borderSide: BorderSide(color: Colors.white),
//              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: '-',
              hintStyle: TextStyle(fontSize: 20.0, color: Color(0xff76d275)),
            ),
            style: TextStyle(color: Color(0xff76d275), fontSize: 30),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
//              _checkCodeValidations();
              setState(() {
//                _forthController.text = _thirdController.text;
//                _firstController.text = "";
//                _secondController.text = value;
//                _firstController.text = "";
//                print("all code: "+_code);
//                print("first code: "+_code[0]);
//
//                if (_code.length == 1) {
//                  _secondController.text = value;
//                  _firstController.text = "";
//                } else if (_code.length == 2) {
//                  print("second code: "+_code[1]);
//                  _thirdController.text = _code[1];
//                  _secondController.text = _code[0];
//                  _firstController.text = "";
//                }
              });
              print('onChanged');
//              if (value != "") {
//                if (currentFocusNode == _forthFocus) {
//                  if (value.length == 1) {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                  }
//                } else {
//                  FocusScope.of(context).requestFocus(nextFocusNode);
//                }
//              } else {
//                FocusScope.of(context).requestFocus(previousFocusNode);
//              }
//              FocusScope.of(context).requestFocus(currentFocusNode);
            },
          ),
          width: 55,
        ),
        Container(
          height: 2,
          width: 45,
          color: controller.text.isEmpty ? Color(0xff76d275) : Colors.white,
          padding: EdgeInsets.all(1),
        )
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      child: Center(
        child: Image.asset(_verifyButtonImage),
      ),
      onTap: _submitAction,
    );
  }

  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_verifyButtonImage == "assets/verified_btn.png") {
      userNetwork.verifyLogin(_userMembership, _code, this);
    }
  }
  void _checknewCodeValidations() {
    print("bhjjhjhjhjhhj");
    String _sysLng = ui.window.locale.languageCode;
    print(_sysLng);
    _code = _controller.text;

    // if (_sysLng == "ar") {
    //   _code = _forthController.text +
    //       _thirdController.text +
    //       _secondController.text +
    //       _firstController.text;
    // } else {
    //   _code = _firstController.text +
    //       _secondController.text +
    //       _thirdController.text +
    //       _forthController.text;
    // }

    setState(() {
      if(_code.length == 4){
        FocusScope.of(context).unfocus();

      }
      _verifyButtonImage = _code.length == 4
          ? "assets/verified_btn.png"
          : "assets/verified_btn_nr.png";
    });
  }

  void _checkCodeValidations() {
    print("bhjjhjhjhjhhj");
    String _sysLng = ui.window.locale.languageCode;
    print(_sysLng);

    if (_sysLng == "ar") {
      _code = _forthController.text +
          _thirdController.text +
          _secondController.text +
          _firstController.text;
    } else {
      _code = _firstController.text +
          _secondController.text +
          _thirdController.text +
          _forthController.text;
    }

    setState(() {
      _verifyButtonImage = _code.length == 4
          ? "assets/verified_btn.png"
          : "assets/verified_btn_nr.png";
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isloading = true;
    });
  }

  @override
  void showGeneralError() {
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {}

  @override
  void showSuccess(String? data) {
    setState(() {
      remainsDuration = 120;
      _timerValue = formatHHMMSS(remainsDuration);
    });
  }

  @override
  void showSuccessLogin(LoginData? data) {
    bool isOldUser = false;
    // _localSettings.setLoginData(data?.copyWith(isMember: true ,  )??LoginData());
    // LocalSettings.loginData =data?.copyWith(isMember: true) ?? LoginData();

    if (data?.token != null) {
      _localSettings.setToken(data?.token??"");
      LocalSettings.token = "Bearer ${data?.token}" ;
      print('token: ${data?.token}');
    }
    if (data?.refresh_token != null) {
      _localSettings.setRefreshToken(data?.refresh_token??"");
      LocalSettings.refreshToken = data?.refresh_token??"";
    }
    if (data?.user != null) {
      _localSettings.setUser(data?.user?.copyWith(isMember: true) ?? User());
      LocalSettings.user = data?.user?.copyWith(isMember: true) ;
      if (data?.user?.user_login_before != null) {
        if (data?.user?.user_login_before == "1") {
          isOldUser = true;
        }
      }
    }
    isOldUser = true;

    if (data?.interests != null) {
      _localSettings.setInterests(data?.interests??[]);
      LocalSettings.interests = data?.interests??[];
    }
    if (isOldUser) {
      widget.postId == null
          ? Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
              (Route<dynamic> route) => false)
          : _checkNotificationNavigation(
              widget.type, widget.postId, widget.from_branch);
    } else {
      //new user so log that mobile user
      if (ApiUrls.RELEASE_MODE) {
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        analytics.logLogin();
      }

      //navigate to set his interests
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Interests(false, null, 0)),
          (Route<dynamic> route) => false);
    }
  }

  void _checkNotificationNavigation(
      String? type, String? postId, bool? from_branch) {
    switch (type) {
      case "event_icon":
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => EventDetails(
                      postId??"0",
                      isFromShare: true,
                    )),
            (Route<dynamic> route) => false);

        break;
      case "service":
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OfferServiceDetails(
                      int.parse(postId??"0"),
                      false,
                      isFromShare: true,
                    )),
            (Route<dynamic> route) => false);
        break;
      case "trip_details":
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => TripDetails(
                      int.parse(postId??"0"),
                      null,
                      true,
                      isFromShare: true,
                    )),
            (Route<dynamic> route) => false);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _setTimer() {
    // int difference = 0;
    if (remainsDuration > 0) {
      setState(() {
        _timerValue = formatHHMMSS(remainsDuration);
      });
      timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        remainsDuration = remainsDuration - 1;
        setState(() {
          print('timer$remainsDuration');

          _timerValue = formatHHMMSS(remainsDuration);
        });
        if (remainsDuration <= 0) {
          print('end timer');
          timer.cancel();
        }
      });
    }
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

//    if (hours == 0) {
//      return "$minutesStr:$secondsStr";
//    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @override
  void showLoginError(String? error) {
    // TODO: implement showLoginError
  }
}
