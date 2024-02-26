import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/opt_authenication.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/validation.dart';

import 'package:fluttertoast/fluttertoast.dart';

class UpdateMembershipStepThree extends StatefulWidget {
  // BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;
  String? userMembership;

  ReloadTripsDelagate? reloadTripsDelagate;

  // bool _isFromPushNotification = false;
  bool? isUpdated;

  UserData? userData;
 bool? redirectToLogin;
  UpdateMembershipStepThree(
      {this.userData, this.userMembership, this.reloadTripsDelagate , this.redirectToLogin=false, this.isUpdated=false});

  @override
  State<StatefulWidget> createState() {
    return UpdateMembershipStepThreeState(
        this.userData, this.userMembership, this.reloadTripsDelagate);
  }
}

class UpdateMembershipStepThreeState extends State<UpdateMembershipStepThree>
    implements RegisterMembershipListener {
  bool _isloading = false;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _membershipController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isShownPhoneError = false;
  bool showInvaildmail = false;
  String? _userMembership;
  UserNetwork userNetwork = UserNetwork();
  UserData? userData;
  User? user_update;
  ReloadTripsDelagate? _reloadTripsDelagate;
  String? last2Chars;
  bool showInvaildId = false;

  UpdateMembershipStepThreeState(
      this.userData, this._userMembership, this._reloadTripsDelagate);

  @override
  void initState() {
    super.initState();
    last2Chars = widget.userData?.member_id?.substring((widget.userData?.member_id?.length??0) - 2)??"";

    // if(widget.isUpdated??false){
    //   _emailController.value = TextEditingValue(text: "");
    //   _phoneController.value = TextEditingValue(text: "");
    // }else{
      widget.userData?.email == null
          ? _emailController.value = TextEditingValue(text: "")
          : _emailController.value =
          TextEditingValue(text: widget.userData?.email??"");
      widget.userData?.phone == null
          ? _phoneController.value = TextEditingValue(text: "")
          : _phoneController.value =
          TextEditingValue(text: widget.userData?.phone??"");
    // }

    _nameController.value = TextEditingValue(text: widget.userData?.name??"");
    _membershipController.value =
        TextEditingValue(text: widget.userData?.member_id.toString()??"");

    _idController.value =
        TextEditingValue(text: widget.userData?.national_id==null?"":widget.userData?.national_id.toString()??"");
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
        child: WillPopScope(
          onWillPop: () async{
            if (_reloadTripsDelagate != null && user_update != null) {
              _reloadTripsDelagate?.reloadTripsAfterBooking(user_update);
            }
            Navigator.of(context).pop(null);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "تحديث البيانات",
              ),
              leading: IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () {
                  if (_reloadTripsDelagate != null && user_update != null) {
                    _reloadTripsDelagate?.reloadTripsAfterBooking(user_update);
                  }
                  Navigator.of(context).pop(null);
                },
              ),
            ),
            // bottomNavigationBar: _buildFooter(),
            body: _buildContent(),
          ),
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
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        child: ListView(
          children: <Widget>[
//          _buildHeader(),
            Container(
              color: Color(0xffeeeeee),
              height: 1,
            ),
//          Container(
//            padding: EdgeInsets.only(top: 20, right: 20),
//            child: Align(
//                child: Text(
//                  'برجاء ادخال البيانات الأتية',
//                  style: TextStyle(
//                      color: Color(0xff00701a),
//                      fontSize: 17,
//                      fontWeight: FontWeight.w700),
//                ),
//                alignment: Alignment.center),
//          ),
            _buildFieldTitle("الاسم بالكامل"),
            _buildInputField(
                "الاسم بالكامل", _nameController, TextInputType.text,
                enable: false),
            _buildFieldTitle("رقم العضوية"),
            _buildInputField(
                "رقم العضوية", _membershipController, TextInputType.number,
                enable: false),
            _buildFieldTitle("الرقم القومي"),
            _buildInputField(
                "الرقم القومي", _idController, TextInputType.number,
                enable: last2Chars != "00" ? true : false),
            showInvaildId
                ? _buildErrorPhoneContent("الرقم القومي غير صحيح ")
                : SizedBox(),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildFieldTitle("رقم الهاتف"),
                Padding(
                  padding: EdgeInsets.only(top: 17),
                  child: Text(
                    '*',
                    style: TextStyle(
                        color: Color(0xffE21B1B),
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                )
              ],
            ),
            _buildInputField(
                "رقم الهاتف", _phoneController, TextInputType.phone),

            isShownPhoneError
                ? _buildErrorPhoneContent( errorMsg??"يرجى ادخال رقم هاتف صحيح ")
                : SizedBox(),

//          emptyID ? _buildFieldError("برجاء إدخال الرقم القومي") : SizedBox(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildFieldTitle("البريد الالكتروني"),
                Padding(
                  padding: EdgeInsets.only(top: 17),
                  child: Text(
                    '*',
                    style: TextStyle(
                        color: Color(0xffE21B1B),
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                )
              ],
            ),

            _buildInputField("البريد الالكتروني", _emailController,
                TextInputType.emailAddress),
            showInvaildmail
                ? _buildErrorPhoneContent("يرجى ادخال بريد إلكتروني صحيح ")
                : SizedBox(),
            SizedBox(
              height: 30,
            ),

            _buildFooter()
          ],
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
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

  Widget _buildSubTitle(String title, double right_align, double top_align) {
    return Padding(
      padding: EdgeInsets.only(right: right_align, top: top_align, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            color: Color(0xff646464),
            fontWeight: FontWeight.w400,
            fontSize: 12,
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

  Widget _buildInputField(
      String title, TextEditingController controller, TextInputType type,
      {enable = true}) {
    double width = MediaQuery.of(context).size.width;

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

  Widget _buildErrorPhoneContent(String error) {
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
//          Expanded(
//            child: GestureDetector(
//              onTap: () {
////              Navigator.push(
////                  context,
////                  MaterialPageRoute(
////                      builder: (BuildContext context) =>
////                          UpdateInfoFirstStep(_controller.text)));
//              },
//              child: Text(
//                'من هنا',
//                style: TextStyle(
//                    color: Color(0xfff12b10),
//                    fontSize: 13,
//                    fontWeight: FontWeight.w700,
//                    decorationThickness: 2,
//                    decoration: TextDecoration.underline),
//              ),
//            ),
//          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 0, right: 15, left: 15, top: 5),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildErrorIDContent() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'رقم قومي غير صحيح',
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              'الرجاء معاودة المحاولة في وقت لاحق',
              style: TextStyle(
                color: Color(0xfff12b10),
                fontSize: 13,
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
          'assets/step03.png',
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
                'تحديث',
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
          if (_emailController.text.isEmpty||_phoneController.text.isEmpty) {
            setState(() {
              showInvaildmail = _emailController.text.isEmpty;
               isShownPhoneError = _phoneController.text.isEmpty;
            });
          }
          else{
            _navigateToNextAction();
          }
        });
  }

  Widget _buildNextStep(String number, String title) {
    return Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                  color: Color(0xffd4d4d4),
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Color(0xffd4d4d4)),
            color: Color(0xfff9f9f9),
          ),
          height: 50,
          width: 50,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: TextStyle(
              color: Color(0xffd4d4d4),
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }


  void _navigateToNextAction() {
    print("here8888");

    Validation _validation = Validation();

    FocusScope.of(context).requestFocus(new FocusNode());
    showInvaildId = false;

    isShownPhoneError = false;
    showInvaildmail = false;
    print("here");

    if (_emailController.text.isNotEmpty) {
      print("here");
      if (last2Chars == "00" && _idController.text.length != 14) {
        showInvaildId = true;
      }
      // if (last2Chars != "00" && _idController.text.isNotEmpty&& _idController.text.length != 14) {
      //   showInvaildId = true;
      // }

      if (!_validation.isEmail(_emailController.text)) {
        setState(() {
          showInvaildmail = true;
        });
      } else {
        showInvaildmail = false;

        if (last2Chars == "00" && _idController.text.length != 14) {
          showInvaildId = true;
          setState(() {});
        } else {
          userNetwork.checkStepThree(_idController.text, _emailController.text,
              _phoneController.text, _userMembership??"", this);
        }
      }
    } else {
      userNetwork.checkStepThree(_idController.text, _emailController.text,
          _phoneController.text, _userMembership??"", this);
    }

//    if (_validateRoomsList()) {
//      if (_validateChildrenList()) {
//        print('Success Data');

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
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
    // setState(() {
    // isShownPhoneError = true;
    // });
  }

  @override
  void showSuccess(String msg) async {
    if (LocalSettings.user != null) {
      user_update = LocalSettings.user??User();
      user_update =
          User(user_email: _emailController.text, phone: _phoneController.text);

      LocalSettings.user = user_update;
    }
    Fluttertoast.showToast(msg:msg, toastLength: Toast.LENGTH_LONG);
  }

  bool isLoginError = false;

  @override
  void showLoginError(String error) {
    setState(() {
      isLoginError = true;
    });
  }

  @override
  void showEmailError({String? errorMsg}) {}

  @override
  void showMemberShipIDError() {}

  String? errorMsg;
  @override
  void showPhoneError(String? error) {
    setState(() {
      errorMsg=error??"";
      isShownPhoneError = true;
    });
  }

  @override
  void showSuccessID(String? msg) {
    if (LocalSettings.user != null) {
      user_update = LocalSettings.user??User();
      user_update = User(
          user_email: _emailController.text,
          phone: _phoneController.text,
          first_name: user_update?.first_name,
          national_id: _idController.text,
          last_name: user_update?.last_name,
          display_name: user_update?.display_name,
          user_name: user_update?.user_name,
          id: user_update?.id,
          user_login: user_update?.user_login,
          membership_no: user_update?.membership_no,
          user_login_before: user_update?.user_login_before,
          notification_sound: user_update?.notification_sound,
          notification_status: user_update?.notification_status);

      LocalSettings.user = user_update;
    }
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
    if(widget.redirectToLogin??false){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => Login(membershipId:_userMembership.toString() ,)),
    );
    }
  }
  @override
  void showSuccessMsgCode(String? msg) {
  }
  @override
  void showErrorMsg(String? error) {

  }
}
