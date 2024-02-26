import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/listeners/UpdateMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/opt_authenication.dart';
import 'package:sporting_club/ui/Update_membership/update/update_step_three.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateMembershipStepTwo extends StatefulWidget {
  // BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;

  //ReloadTripsDelagate _reloadTripsDelagate;
  // bool _isFromPushNotification = false;

  String _userMembership = "";
  String successMsg = "";

  UpdateMembershipStepTwo(this._userMembership, this.successMsg);

  @override
  State<StatefulWidget> createState() {
    return UpdateMembershipStepTwoState();
  }
}

class UpdateMembershipStepTwoState extends State<UpdateMembershipStepTwo>
    implements UpdateMembershipListener {
  bool _isloading = false;
  final _nationalIdController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool isShownIDError = false;
  bool isShownIDAndBirthdateError = false;
  bool isShownBirthDayError = false;
  UserNetwork userNetwork = UserNetwork();
  bool emptyID = false,sizeIdError =false;
  String msg = "";

  UpdateMembershipStepTwoState();

  String last2Chars = "";

  @override
  void initState() {
    last2Chars =
        widget._userMembership.substring(widget._userMembership.length - 2);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "تحديث البيانات",
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
//          bottomNavigationBar: _buildFooter(),
          body: _buildContent(),
        ),
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: ListView(
        children: <Widget>[
//          _buildHeader(),
          Container(
            color: Color(0xffeeeeee),
            height: 1,
          ),

          Container(
            padding: EdgeInsets.only(top: 20, right: 20),
            child: Align(
                child: Text(
                  'برجاء ادخال البيانات الأتية',
                  style: TextStyle(
                      color: Color(0xff00701a),
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                alignment: Alignment.center),
          ),
          ( last2Chars == "00")?
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildFieldTitle("الرقم القومي"),
              last2Chars == "00"?  Padding(
                padding: EdgeInsets.only(top: 17),
                child: Text(
                  '*',
                  style: TextStyle(
                      color: Color(0xffE21B1B),
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
              ) :SizedBox()
            ],
          )
        : SizedBox(),

          ( last2Chars == "00")?
          _buildInputField(
              "الرقم القومي", _nationalIdController, TextInputType.number)
        : SizedBox(),
    (emptyID && last2Chars == "00")
              ? _buildFieldError("برجاء إدخال الرقم القومي")
              : SizedBox(),
          (sizeIdError )
              ? _buildFieldError("الرقم القومى غير صحيح")
              : SizedBox(),
          last2Chars == "00"
              ? SizedBox():  _buildFieldTitle("تاريخ الميلاد"),
          last2Chars == "00"
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    _selectedDate(context);
                  },
                  child: _buildInputField("تاريخ الميلاد", _birthdayController,
                      TextInputType.datetime,
                      enable: false),
                ),

          SizedBox(
            height: 20,
          ),
          isShownBirthDayError
              ? _buildErrorBirthDateContent("يرجى ادخال تاريخ الميلاد")
              : SizedBox(),

         isShownIDError ? _buildErrorIDContent(msg) : SizedBox(),
          isShownIDAndBirthdateError ? _buildErrorIDANDBirthdateContent() : SizedBox(),

          SizedBox(
            height: 40,
          ),
          _buildFooter(),

        ],
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 15, top: 20, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            color: Color(0xff646464),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildFieldError(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 5, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: Colors.red,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  DateTime _date = DateTime.now();
  DateTime _dateNow = DateTime.now();

  Future<Null> _selectedDate(BuildContext context) async {
    _date = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(1900),
        lastDate: _dateNow);

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _birthdayController.value =
            TextEditingValue(text: picked.toString().split(" ")[0]);
      });
    }
  }

  Widget _buildInputField(
    String title,
    TextEditingController controller,
    TextInputType type, {
    enable = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 15, top: 5, left: 15),
      child: Container(
        child: TextField(
          enabled: enable,
          controller: controller,
          style: TextStyle(fontSize: 16, color: Colors.black),
          maxLines: 1,
          // textInputAction: TextInputAction.newline,
          decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 12, bottom: 10, top: 15, right: 12),
            hintText: title,
          ),
          keyboardType: type,
          keyboardAppearance: Brightness.light,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(32),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 8.0, // has the effect of softening the shadow
              spreadRadius: 0.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
        ),
//        width: width - 30,
        height: 60,
      ),
    );
  }

  Widget _buildErrorBirthDateContent(String error) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            error,
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildErrorIDContent(msg) {
    int index = msg.toString().lastIndexOf(" ");
    String content = msg.toString().substring(0, index);
    String email = msg.toString().substring(index + 1);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.max,
        children: <Widget>[
//          Text(
//            'الرقم القومي غير مطابق للرقم المسجل في قاعدة البيانات. يرجى إرسال ايميل على it@alexsportingclub.com',
//            style: TextStyle(
//              color: Color(0xfff12b10),
//              fontSize: 12,
//              fontWeight: FontWeight.w700,
//
//
//            ),
//            maxLines: 7,
//            textDirection: TextDirection.rtl,
//          ),
//          SizedBox(
//            width: 5,
//          ),
          Text(
            msg,
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          // InkWell(
          //   onTap: (){
          //     _launchURL(email);
          //   },
          //   child: Text(
          //     email,
          //     style: TextStyle(
          //         color:  Color(0xff43a047),
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         decoration: TextDecoration.underline,
          //       decorationThickness: 4,
          //
          //     ),
          //     textDirection: TextDirection.rtl,
          //
          //   ),
          // ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 0, left: 0),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  _launchURL(String toMailId) async {
    var url = 'mailto:$toMailId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget _buildErrorIDContent1() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
//          Text(
//            'الرقم القومي غير مطابق للرقم المسجل في قاعدة البيانات. يرجى إرسال ايميل على it@alexsportingclub.com',
//            style: TextStyle(
//              color: Color(0xfff12b10),
//              fontSize: 12,
//              fontWeight: FontWeight.w700,
//
//
//            ),
//            maxLines: 7,
//            textDirection: TextDirection.rtl,
//          ),
//          SizedBox(
//            width: 5,
//          ),
          Expanded(
            child: Text(
              'الرقم القومي غير مطابق للرقم المسجل في قاعدة البيانات. يرجى إرسال ايميل على it@alexsportingclub.com',
              style: TextStyle(
                color: Color(0xfff12b10),
                fontSize: 13,
                fontWeight: FontWeight.w600,

              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }
  Widget _buildErrorIDANDBirthdateContent() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "برجاء ادخال الرقم القومي او تاريخ الميلاد",
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildHeader() {
    double width = MediaQuery.of(context).size.width;
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

  Widget _buildFooter() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
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
        onTap: () {
          if( last2Chars != "00"){
            submitFollowerData();
          }else{
            _navigateToNextAction();
          }
        });
  }

  void _navigateToNextAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_nationalIdController.text.isEmpty && last2Chars == "00") {
      setState(() {
        emptyID = true;
        isShownIDError = false;
        isShownBirthDayError = false;
        isShownIDAndBirthdateError=false;
        sizeIdError = false;

      });
    } else if (_birthdayController.text.isEmpty &&
        _nationalIdController.text.isEmpty &&
        last2Chars != "00") {
      setState(() {
        emptyID = false;
        sizeIdError = false;
        isShownIDError = false;
        isShownIDAndBirthdateError=true;
        isShownBirthDayError = false;
      });
      Fluttertoast.showToast(msg:"برجاء ادخال اي معلومات", toastLength: Toast.LENGTH_LONG);
    }
    else if (_nationalIdController.text.isNotEmpty && _nationalIdController.text.length
        !=14) {
      emptyID = false;
      isShownIDError = false;
      sizeIdError = true;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError=false;
    }
    else {
      isShownIDError = false;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError=false;
      sizeIdError = false;
      emptyID = false;

      userNetwork.checkStepTwo(
          _nationalIdController.text, _birthdayController.text,widget._userMembership, this);
    }
  }

  void submitFollowerData() {
    FocusScope.of(context).requestFocus(new FocusNode());
      if (_birthdayController.text.isEmpty &&
        last2Chars != "00") {
      setState(() {
        isShownBirthDayError = false;
      });
      Fluttertoast.showToast(msg:"برجاء ادخال اي معلومات", toastLength: Toast.LENGTH_LONG);
    }
  else {
      isShownIDError = false;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError=false;
      sizeIdError = false;
      emptyID = false;

      userNetwork.checkStepTwo(
          _nationalIdController.text, _birthdayController.text,widget._userMembership, this);
    }
  }

  @override
  void extendTime(String time) {
    // TODO: implement extendTime
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
    // Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
    setState(() {
      this.msg = msg??"";
      isShownIDError = true;
    }); }

  @override
  void showAuthError() {
    setState(() {
      isShownIDError = true;
    });
  }

  @override
  Future<void> showSecondStepSuccess(UserData? userData, bool? isUpdated, String? msg) async {
    if(isUpdated??false){
       Fluttertoast.showToast(msg:
          msg??"قد تم اضافة الرقم القومي",
          toastLength: Toast.LENGTH_LONG);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UpdateMembershipStepThree(userData: userData,userMembership: widget._userMembership
                ,reloadTripsDelagate: null, isUpdated: isUpdated, )));
  }

  @override
  void showSuccessID(String msg) {

  }
  bool isLoginError = false;

  @override
  void showLoginError(String error) {
    setState(() {
      isLoginError = true;
    });
  }

  @override
  void showEmailError() {
//    setState(() {
//      isShownBirthDayError = true;
//    });
  }
  @override
  void showError(String? error) {
    Fluttertoast.showToast(msg:
        error??"",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showMemberShipIDError() {
    setState(() {
      isShownIDError = true;
    });
    // TODO: implement showMemberShipIDError
  }

  @override
  void showPhoneError() {}

  @override
  void showSuccess(String? msg) {
    // TODO: implement showSuccess
  }
}
