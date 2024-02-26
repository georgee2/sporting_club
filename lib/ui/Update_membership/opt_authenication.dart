import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/payment_membership.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/update_info/update_info_firstStep.dart';
import 'package:sporting_club/ui/update_info/update_info_secondStep.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui' as ui;

class OtpAuthenication extends StatefulWidget {
  String _userMembership = "",_email = "",_phone = "";
  String successMsg= "";
  OtpAuthenication(this._userMembership ,this._email,this._phone, this.successMsg);

  @override
  State<StatefulWidget> createState() {
    return OtpAuthenicationState(this._userMembership,this._email,this._phone, this.successMsg);
  }
}

class  OtpAuthenicationState extends State<OtpAuthenication>
    implements PaymentResponseListener,RegisterMembershipListener {
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
  String _userMembership = "",_email = "",_phone = "",successMsg = "";
  LocalSettings _localSettings = LocalSettings();
  bool _invalidcode= false;

  OtpAuthenicationState(this._userMembership,this._email,this._phone, this.successMsg);

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
    return ModalProgressHUD(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .primaryColor,
// <-- APPBAR WITH TRANSPARENT BG
        title: Container(

          child:Text(
            "تجديد الاشتراك السنوي        ",
            textDirection: TextDirection.rtl,

          ),

        ),
          actions: <Widget>[
            new IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),

          ],
          leading: new Container(
            margin: EdgeInsets.only(right: 20, left: 10),
          ),
          // <-- ELEVATION ZEROED
          automaticallyImplyLeading:
          true, // Used for removing back buttoon.
        ),
//          AppBar(
//            backgroundColor: Theme
//                .of(context)
//                .primaryColor,
//
//            title: Text(
//              "تجديد الاشتراك السنوي",
//              textDirection: TextDirection.rtl,
//
//            ),
//            leading: IconButton(
//              icon: new Image.asset('assets/back_white.png'),
//              onPressed: () => Navigator.of(context).pop(null),
//            ),
//          ),
          bottomNavigationBar: _buildFooter(),
          body: _buildContent(),
        ),
      inAsyncCall: _isloading,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
        AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }


  Widget _buildContent() {
    return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
    child: Container(child:
    ListView(
      children: <Widget>[
        _buildHeader(),
        Container(
          color: Color(0xffeeeeee),

          height: 1,
        ),

        Container(
          padding: EdgeInsets.only(top: 20, right: 20,left:20),
          child: Align(
              child: Text(
                'ادخل كود التعريف',
                style: TextStyle(
                    color: Color(0xff00701a),
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
                textDirection: TextDirection.rtl,
              ),
              alignment: Alignment.center),
        ),
      Container(
        padding: EdgeInsets.only( right: 20,left:20),
       child: Align(
          child: Text(
            successMsg,
            style: TextStyle(
                color: Color(0xff03240A),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            textDirection: TextDirection.rtl,

          ),
          alignment: Alignment.center),
      ),
        SizedBox(
          height: 50,
        ),
        // Container(
        //   child: TextField(
        //     controller: _controller,
        //     textAlign: TextAlign.center,
        //     autofocus: true,
        //   //  cursorColor: Colors.white,
        //     onChanged: (value) {
        //       _checknewCodeValidations();
        //
        //     },
        //     style: TextStyle(color: Colors.white),
        //
        //     decoration: new InputDecoration(
        //         border: InputBorder.none,
        //
        //         focusedBorder: InputBorder.none,
        //         contentPadding:
        //         EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        //         hintText: 'كود التفعيل',
        //         counterText: ''
        //
        //     ),
        //     keyboardType: TextInputType.number,
        //     keyboardAppearance: Brightness.light,
        //     maxLength: 4,
        //     inputFormatters: <TextInputFormatter>[
        //
        //       FilteringTextInputFormatter.digitsOnly,
        //     ],
        //   ),
        //   decoration: new BoxDecoration(
        //     color: Theme
        //         .of(context)
        //         .primaryColor,
        //     border: Border.all(color: Colors.white),
        //     borderRadius: new BorderRadius.all(Radius.circular(5)),
        //   ),
        //   height: 50,
        //   margin: EdgeInsets.only(bottom: 5, top: 10,left: 60,right: 60),
        //   padding: EdgeInsets.all(1),
        //
        // ),
        Center(
          child: Container(
            child:IntrinsicWidth(child:
            TextField(
              controller: _controller,
              textAlign: TextAlign.left,

              style: TextStyle(
                  letterSpacing: 38,
                  fontSize: 20.0,
                  color:  Color(0xff76d275)
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
              margin: EdgeInsets.only(bottom: 5, top: 10,left: 0,right: 0),
            padding: EdgeInsets.all(1),


          ),
        ),

        _buildVerificationCode(),
      SizedBox(
        height: 50,
      ),
        _invalidcode? _buildErrorIDContent("",""):SizedBox(),

      ],
    ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    )
    );
  }
  Widget _buildVerificationCode() {
    return Row(
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

      ],
    );
  }


  Widget _buildHeader() {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double viewWidth = width - 150;

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),

        child: Image.asset(
          'assets/step02.png',
//          width: viewWidth,
          height: 70,
          fit: BoxFit.fitHeight,
        ),
      ),
      color: Colors.white,
//      height: 120,
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
//             autofocus: true,
//             decoration: new InputDecoration(
// //              enabledBorder: UnderlineInputBorder(
// //                  borderSide: BorderSide(color: Color(0xff76d275))),
// //              focusedBorder: UnderlineInputBorder(
// //                borderSide: BorderSide(color: Colors.white),
// //              ),
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
//         Container(
//           height: 2,
//           width: 45,
//           color: controller.text.isEmpty ?Color.fromRGBO( 96, 100, 112, 0.1):Color(0xff76d275) ,
//           padding: EdgeInsets.all(1),
//         ),


        Container(
          height: 2,
          width: 35,
          color: _controller.text.length < 4 ? Color.fromRGBO( 96, 100, 112, 0.1):Color(0xff76d275) ,
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
            'اذا تم تغيير رقم الهاتف',
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
                      builder: (BuildContext context) => UpdateInfoFirstStep(widget._userMembership)));
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




  Widget _buildErrorIDContent(value1,value2) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[

          Text(
            "كود التفعيل غير صحيح. برجاء المحاولة مرة أخرى",
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
              fontWeight: FontWeight.w700,

            ),
          ),
          SizedBox(
            height: 5,

          ),
      GestureDetector(
        child:
          Text(
            "إعادة إرسال كود التفعيل",

            style: TextStyle(
              color: Color(0xff646464),
              fontSize: 14,
              fontWeight: FontWeight.w600,
                decorationThickness: 2,
                decoration: TextDecoration.underline


            ),
          ),
        onTap:(){
          print("here");

          userNetwork.registerPayment(
              _userMembership, _email, _phone,
              this);
        } ,
      ),
         ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery
          .of(context)
          .size
          .width,
//      decoration: new BoxDecoration(
//          color: Color(0xffffeae3)
//          ,
//          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }


  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_verifyButtonImage == "assets/verified_btn.png") {
      userNetwork.verifyLoginPayment(_code,_userMembership,true, this);
    }
  }

  void _checkCodeValidations() {
    print("bhjjhjhjhjhhj");
   String _sysLng = ui.window.locale.languageCode;
    print(_sysLng);

    if(_sysLng == "ar"){
      _code = _forthController.text +
          _thirdController.text +
          _secondController.text +
          _firstController.text;
    }else{
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
  void showSuccess(PaymentData? data, {String? serverMessage}) {
    print('server message in otp');
    bool isOldUser = false;
    setState(() {
      _invalidcode = false;
    });
    print("sucess");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                PaymentMembership(
                  data??PaymentData(), serverMessage??"",_code
                )));
   print(data);
  }
  Widget _buildFooter() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15,bottom: 20),
          child: Container(
            width: 88,
            height: 60,
            child: Center(
              child: Text(
                'التالي',
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
        onTap: () => _navigateToNextAction());
  }

  void _navigateToNextAction() {
//6951
    _submitAction();
//    if (_validateRoomsList()) {
//      if (_validateChildrenList()) {
//        print('Success Data');
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (BuildContext context) => OtpAuthenication(
//                "25",""
//            )));
//      } else {
//        Fluttertoast.showToast(msg:'برجاء إختيار عمر الطفل', context,
//            duration: Toast.LENGTH_LONG);
//      }
//    } else {
//      Fluttertoast.showToast(msg:'برجاء استكمال بيانات الغرفة', context,
//          duration: Toast.LENGTH_LONG);
//    }
  }

  @override
  void showInvalidCode(String? data) {
       setState(() {
         _invalidcode = true;
       });

  }

  @override
  void showEmailError({String? errorMsg}) {
    // TODO: implement showEmailError
  }

  @override
  void showMemberShipIDError() {
    // TODO: implement showMemberShipIDError
  }

  @override
  void showPhoneError(String? error) {
    // TODO: implement showPhoneError
  }

  @override
  void showSuccessID(String? msg) {
    if(_phone.isEmpty){
      Fluttertoast.showToast(msg:'سيتم إرسال بريد إلكتروني  بكود التفعيل ', toastLength: Toast.LENGTH_LONG);
    }else{
      Fluttertoast.showToast(msg:'سيتم إرسال رسالة نصية بكود التفعيل ', toastLength: Toast.LENGTH_LONG);
    }
//    Fluttertoast.showToast(msg:'سيتم إرسال رسالة نصية بكود التفعيل ', context,
//        duration: Toast.LENGTH_LONG);
  }
  @override
  void showSuccessMsgCode(String? msg) {
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

  @override
  void showErrorMsg(String? error) {
  }
}
