import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/user_data.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/update/update_step_three.dart';
import 'package:sporting_club/ui/login/verify_login.dart';
import 'package:sporting_club/ui/update_info/update_info_secondStep.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sporting_club/network/listeners/UpdateMembershipListener.dart';

class UpdateInfoFirstStep extends StatefulWidget {
  String _userMembership = "";

  UpdateInfoFirstStep(this._userMembership);

  @override
  State<StatefulWidget> createState() {
    return UpdateInfoFirstStepState();
  }
}

class UpdateInfoFirstStepState extends State<UpdateInfoFirstStep>
    implements UpdateMembershipListener {
  final _nationalIdController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool _isValid = true;
  String _errorValue = "";
  bool emptyID = false,
      sizeIdError = false;

  UserNetwork userNetwork = UserNetwork();
  bool _isloading = false;
  Image myImage= Image.asset('assets/shape.png');
  bool isnotvalid = false;
  bool isShownIDError = false;
  String msg = "";
  String last2Chars = "";

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
//    precacheImage(new AssetImage('assets/shape.png'), context);
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
  }

  @override
  void initState() {
    print('initState');
    super.initState();
    last2Chars =
        widget._userMembership.substring(widget._userMembership.length - 2);

    myImage = Image.asset('assets/shape.png');
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return ModalProgressHUD(
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
            backgroundColor: Colors.transparent,
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
                  padding: EdgeInsets.all(25),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Align(
              child: Image.asset(
                'assets/sporting_logo.png',
                fit: BoxFit.fill,
                height: 100,
                width: 100,
              ),
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 5,
            ),
            Align(
              child: Text(
                'تحديث المعلومات',
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xff76d275),
                  fontWeight: FontWeight.w700,
                ),
              ),
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 5,
            ),
            Align(
              child: Text(
                'الخطوة الاولى',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              alignment: Alignment.center,
            ),
//            SizedBox(
//              height: 70,
//            ),
            ( last2Chars == "00")?
            _buildInputField()        : SizedBox(),

            last2Chars == "00"
                ? SizedBox() : _buildBirthDateInputField(),
            isShownIDAndBirthdateError
                ? _buildErrorIDANDBirthdateContent()
                : SizedBox(),

            SizedBox(
              height: 30,
            ),
            _buildSubmitButton(),
            SizedBox(
              height: 10,
            ),
            isShownIDError ? _buildErrorIDContent(msg) : SizedBox(),
            //isShownIDError isnotvalid
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      children: <Widget>[
        Align(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              last2Chars == "00" ? Padding(
                padding: EdgeInsets.only(top: 30, right: 0),
                child: Text(
                  '*',
                  style: TextStyle(
                      color: Color(0xffE21B1B),
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
              ) : SizedBox(), Container(
                child: Text(
                  'قم بادخال الرقم القومي',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                margin: EdgeInsets.only(left: 10, top: 25),
              ),

            ],
          ),
          alignment: Alignment.center,
        ),

        Container(
          child: TextField(
            controller: _nationalIdController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'الرقم القومي',
            ),
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: new BorderRadius.all(Radius.circular(5)),
          ),
          height: 50,
          margin: EdgeInsets.only(bottom: 5, top: 10),
          padding: EdgeInsets.all(1),
        ),
        Align(
          child: Visibility(
            child: Container(
              child: Text(
                _errorValue,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              padding: EdgeInsets.only(left: 15, bottom: 11, top: 4, right: 15),
            ),
            visible: (emptyID && last2Chars == "00") ||
                sizeIdError, // !_isValid,
          ),
          alignment: Alignment.topRight,
        ),
      ],
    );
  }

  bool isShownIDAndBirthdateError = false;
  bool isShownBirthDayError = false;

  Widget _buildBirthDateInputField() {
    return Column(
      children: <Widget>[
        Align(
          child: Container(
            child: Text(
              'قم بادخال تاريخ الميلاد',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            margin: EdgeInsets.only(left: 25, top: 25),
          ),
          alignment: Alignment.center,
        ),

        InkWell(
          onTap: () {
            _selectedDate(context);
          },
          child:
          Container(
            child: TextField(
              controller: _birthdayController,
              textAlign: TextAlign.right,
              enabled: false,
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "تاريخ الميلاد",
              ),
              keyboardType: TextInputType.datetime,
              keyboardAppearance: Brightness.light,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            decoration: new BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: new BorderRadius.all(Radius.circular(5)),
            ),
            height: 50,
            margin: EdgeInsets.only(bottom: 5, top: 10),
            padding: EdgeInsets.all(1),
          ),

        ),
        Align(
          child: Visibility(
            child: Container(
              child: Text(
                "يرجى ادخال تاريخ الميلاد",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              padding: EdgeInsets.only(left: 15, bottom: 11, top: 4, right: 15),
            ),
            visible: isShownBirthDayError,
          ),
          alignment: Alignment.topRight,
        ),

        // SizedBox(
        //   height: 20,
        // ),
        // isShownBirthDayError
        //     ? _buildErrorBirthDateContent("يرجى ادخال تاريخ الميلاد")
        //     : SizedBox(),
      ],
    );
  }

  Widget _buildErrorIDANDBirthdateContent() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  DateTime _date= DateTime.now();
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

  Widget _buildSubmitButton() {
    return GestureDetector(
      child: Container(
        child: Center(
          child: Text(
            'التاكيد و المتابعه',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 20, top: 10),
        decoration: new BoxDecoration(
            color: Color.fromRGBO(255, 92, 70, 1),
            borderRadius: new BorderRadius.all(Radius.circular(5))),
        height: 50,
      ),
      onTap: _submitAction,
    );
  }

  Widget _buildErrorContent() {
    return GestureDetector(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              'رقم الهاتف غير موجود',
              style: TextStyle(
                color: Color.fromRGBO(0, 112, 26, 1),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'يرجى تحديث المعلومات',
              style: TextStyle(
                color: Color.fromRGBO(0, 112, 26, 1),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 20, top: 10),
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(5))),
      ),
      onTap: (){
        if( last2Chars != "00"){
          _submitFollowerAction();
        }else{
          _submitAction();
        }
      },
    );
  }

  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_nationalIdController.text.isEmpty && last2Chars == "00") {
      setState(() {
        emptyID = true;
        isShownIDError = false;
        isShownBirthDayError = false;
        isShownIDAndBirthdateError = false;
        sizeIdError = false;
      });
    } else if (_birthdayController.text.isEmpty &&
        _nationalIdController.text.isEmpty &&
        last2Chars != "00") {
      setState(() {
        emptyID = false;
        sizeIdError = false;
        isShownIDError = false;
        isShownIDAndBirthdateError = true;
        isShownBirthDayError = false;
      });
      Fluttertoast.showToast(msg:"برجاء ادخال اي معلومات", toastLength: Toast.LENGTH_LONG);
    }
    else if (_nationalIdController.text.isNotEmpty &&
        _nationalIdController.text.length
            != 14) {
      emptyID = false;
      isShownIDError = false;
      sizeIdError = true;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError = false;
      setState(() {
        _errorValue = "الرقم القومى غير صحيح";
      });
    }
    else {
      isShownIDError = false;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError = false;
      sizeIdError = false;
      emptyID = false;

      userNetwork.checkStepTwo(
          _nationalIdController.text, _birthdayController.text,
          widget._userMembership, this);
    }
  }
  void _submitFollowerAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_birthdayController.text.isEmpty &&
        last2Chars != "00") {
      setState(() {
        emptyID = false;
        sizeIdError = false;
        isShownIDError = false;
        isShownIDAndBirthdateError = true;
        isShownBirthDayError = false;
      });
      Fluttertoast.showToast(msg:"برجاء ادخال اي معلومات", toastLength: Toast.LENGTH_LONG);
    }
    else {
      isShownIDError = false;
      isShownBirthDayError = false;
      isShownIDAndBirthdateError = false;
      sizeIdError = false;
      emptyID = false;
      userNetwork.checkStepTwo(
          _nationalIdController.text, _birthdayController.text,
          widget._userMembership, this);
    }
  }

  void _submitAction1() {
    FocusScope.of(context).requestFocus(new FocusNode());
    isnotvalid = false;
    _isValid = false;
    isShownBirthDayError = false;
    isShownIDAndBirthdateError = false;
    if (_nationalIdController.text.isEmpty &&
        _birthdayController.text.isEmpty) {
      setState(() {
        _errorValue = "برجاء إدخال  الرقم القومي";
        _isValid = false;
        isShownBirthDayError = false;
        isShownIDAndBirthdateError = true;
      });
    }
    else if (_nationalIdController.text.isNotEmpty &&
        _nationalIdController.text.length != 14) {
      setState(() {
        _errorValue = "الرقم القومى غير صحيح";
        isShownBirthDayError = false;
        isShownIDAndBirthdateError = false;
        _isValid = false;
      });
    } else if (_birthdayController.text.isEmpty &&
        _nationalIdController.text.isEmpty) {
      setState(() {
        _isValid = false;
        isShownIDAndBirthdateError = true;
        isShownBirthDayError = false;
      });
      Fluttertoast.showToast(msg:"برجاء ادخال اي معلومات", toastLength: Toast.LENGTH_LONG);
    }

    else {
      setState(() {
        _isValid = true;
        isShownBirthDayError = false;
        isShownIDAndBirthdateError = false;
      });
      // userNetwork.checkNationalId(_controller.text, this);
      userNetwork.checkStepTwo(
          _nationalIdController.text, _birthdayController.text,
          widget._userMembership, this);
      //
    }
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
    setState(() {
      this.msg = msg??"";
      isnotvalid = true;
      isShownIDError = true;
    });
    // Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    // TODO: implement showAuthError
  }

  @override
  void showSuccess(String? successMsg) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) => UpdateInfoSecondStep(
    //             widget._userMembership, _nationalIdController.text)));
  }

  @override
  void showSecondStepSuccess(UserData? userData, bool? isUpdated, String? msg) {
    if(isUpdated??false){

   Fluttertoast.showToast(msg:
       msg??"قد تم اضافة الرقم القومي",
       toastLength: Toast.LENGTH_LONG);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                UpdateMembershipStepThree(
                  userData: userData, userMembership: widget._userMembership
                  , reloadTripsDelagate: null, redirectToLogin: true, isUpdated: isUpdated, )));
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


  // @override
  // void showLoginError(String error) {
  //   Fluttertoast.showToast(msg:error, toastLength: Toast.LENGTH_LONG);
  // }

  Widget _buildErrorIDContent(msg) {
    int index = msg.toString().lastIndexOf(" ");
    String content = msg.toString().substring(0, index);
    String email = msg.toString().substring(index + 1);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
          //   onTap: () {
          //     _launchURL(email);
          //   },
          //   child: Text(
          //     email,
          //     style: TextStyle(
          //       color: Color(0xff43a047),
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //       decoration: TextDecoration.underline,
          //       decorationThickness: 4,
          //     ),
          //     textDirection: TextDirection.rtl,
          //
          //   ),
          // ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 0, left: 0),
      width: MediaQuery
          .of(context)
          .size
          .width,
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
}
