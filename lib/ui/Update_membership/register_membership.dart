import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/opt_authenication.dart';
import 'package:sporting_club/ui/Update_membership/update/update_membership.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/validation.dart';

import 'package:fluttertoast/fluttertoast.dart';

class RegisterMembership extends StatefulWidget {
  // BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;

  //ReloadTripsDelagate _reloadTripsDelagate;
  // bool _isFromPushNotification = false;

  RegisterMembership();

  @override
  State<StatefulWidget> createState() {
    return RegisterMembershipState();
  }
}

class RegisterMembershipState extends State<RegisterMembership>
    implements RegisterMembershipListener {
  bool _isloading = false;
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isShownPhoneError = false;
  bool isShownIDError = false;
  bool isShownEmailError = false;
  UserNetwork userNetwork = UserNetwork();
  bool emptyID = false;
  bool emptymail_phone = false;
  bool _notValidEmail = false;
  User user = User();
  var membership_id = "";

  RegisterMembershipState();

  @override
  void initState() {
    super.initState();
    if (LocalSettings.user != null) {
      this.user = LocalSettings.user??User();
    }
    membership_id = user.membership_no.toString();

    print("membership${membership_id})");
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
              "تجديد الاشتراك السنوي",
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          //   bottomNavigationBar: _buildFooter(),
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
    //FocusScope.of(context).requestFocus(new FocusNode());
    var last2Chars = membership_id.substring(membership_id.length - 2);
    print("last2char${last2Chars}");

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
            _buildHeader(),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildFieldTitle("رقم العضوية"),
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
                "رقم العضوية", _idController, TextInputType.number),
            emptyID ? _buildFieldError("برجاء إدخال رقم العضوية") : SizedBox(),
            _buildFieldTitle("البريد الالكتروني"),
            _buildSubTitle(
                'برجاء ادخال البريد الالكترونى الذى سيتم ارسال الفاتورة عليه',
                15,
                2),
            _buildInputField("البريد الالكتروني", _emailController,
                TextInputType.emailAddress),
            _notValidEmail
                ? _buildFieldError("يرجى إضافة بريد إلكتروني صحيح")
                : SizedBox(),
            _buildFieldTitle("رقم الهاتف"),
            _buildInputField(
                "رقم الهاتف", _phoneController, TextInputType.phone),
            Align(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '*',
                      style: TextStyle(
                          color: Color(0xff646464),
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                    Expanded(
                      child: _buildSubTitle(
                          'رقم الهاتف اختيارى و اذا لم يتم ادخاله سيتم التحقق عن طريق البريد الالكترونى المسجل بقاعدة البيانات',
                          1,
                          10),
                    ),
                  ],
                ),
              ),
              alignment: Alignment.topRight,
            ),
            SizedBox(
              height: 20,
            ),
            isShownPhoneError
                ? _buildErrorPhoneContent(
                    errorMsg ?? "يرجى ادخال رقم هاتف صحيح او قم بتحديث بياناتك")
                : SizedBox(),
            isShownEmailError
                ? _buildErrorPhoneContent(
                errorMsg ?? "يرجى ادخال البريد الالكترونى  او قم بتحديث بياناتك")
                : SizedBox(),
            emptymail_phone
                ? _buildErrorIDContent(
                    "برجاء ادخال رقم الهاتف او البريد الالكتروني", "")
                : SizedBox(),
            isShownIDError
                ?_buildErrorIDContent(errorMsg??"", "")
            // last2Chars == "00"
            //         ? _buildErrorIDContent("رقم عضوية غير صحيح",
            //             "الرجاء معاودة المحاولة في وقت لاحق")
            //         : _buildErrorIDContent("رقم عضوية غير صحيح",
            //             "برجاء الدخول و الدفع برقم عضوية اساسى")
                : SizedBox(),
            SizedBox(
              height: 20,
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
      String title, TextEditingController controller, TextInputType type) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, top: 5, left: 15),
      child: Container(
        child: TextField(
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
      child: Wrap(
        // mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            error +" ",
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: () {
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) =>
//                          UpdateInfoFirstStep(_controller.text)));
            },
            child: GestureDetector(
              child: Text(
                'قم بتحديث بياناتك من هنا',
                style: TextStyle(
                    color: Color(0xfff12b10),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decorationThickness: 2,
                    decoration: TextDecoration.underline),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            UpdateMembership()));
              },
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

  Widget _buildErrorIDContent(value1, value2) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            value1 + " " + value2,
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 5,
          ),
//          Expanded(child:
//          Text(
//            value2,
//            style: TextStyle(
//              color: Color(0xfff12b10),
//              fontSize: 13,
//            ),
//          ),
//          ),
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
          'assets/step01.png',
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
          _navigateToNextAction();
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
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_idController.text.isEmpty) {
      setState(() {
        emptyID = true;
        isShownIDError = false;
        isShownEmailError = false;
        isShownPhoneError = false;
        emptymail_phone = false;
      });
    } else if (_emailController.text.isEmpty && _phoneController.text.isEmpty) {
      //&& _phoneController.text.isEmpty
      setState(() {
        emptyID = false;
        isShownIDError = false;
        isShownEmailError = false;
        isShownPhoneError = false;
        emptymail_phone = true;
        _notValidEmail = false;
      });
      //برجاء ادخال رقم التليفون او البريد الالكتروني

    } else {
      Validation _validation = Validation();
      if (_emailController.text.isNotEmpty) {
        if (!_validation.isEmail(_emailController.text)) {
          setState(() {
            isShownIDError = false;
            isShownEmailError = false;
            isShownPhoneError = false;
            emptymail_phone = false;
            emptyID = false;
            _notValidEmail = true;
          });
        } else {
          isShownIDError = false;
          isShownEmailError = false;
          isShownPhoneError = false;
          emptymail_phone = false;
          emptyID = false;
          _notValidEmail = false;

          userNetwork.registerPayment(_idController.text, _emailController.text,
              _phoneController.text, this);
        }
      } else {
        isShownIDError = false;
        isShownEmailError = false;
        isShownPhoneError = false;
        emptymail_phone = false;
        emptyID = false;
        _notValidEmail = false;

        userNetwork.registerPayment(_idController.text, _emailController.text,
            _phoneController.text, this);
      }
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
    setState(() {
      isShownIDError = true;
      emptyID = false;
      isShownEmailError = false;
      isShownPhoneError = false;
      emptymail_phone = false;
      _notValidEmail = false;
    });
  }

  @override
  void showSuccessID(String? msg) {
    if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg:'سيتم إرسال بريد إلكتروني  بكود التفعيل ', toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(msg:'سيتم إرسال رسالة نصية بكود التفعيل ', toastLength: Toast.LENGTH_LONG);
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => OtpAuthenication(
                  _idController.text,
                  _emailController.text,
                  _phoneController.text,
                  msg??"",
                )));
  }

  bool isLoginError = false;

  @override
  void showLoginError(String error) {
    setState(() {
      isLoginError = true;
    });
  }

  @override
  void showEmailError({String? errorMsg}) {
    setState(() {
      isShownEmailError = true;
      this.errorMsg = errorMsg;

    });
  }

  @override
  void showMemberShipIDError() {
    setState(() {
      isShownIDError = true;
    });
    // TODO: implement showMemberShipIDError
  }

  String? errorMsg;

  @override
  void showPhoneError(String? error) {
    setState(() {
      errorMsg = error;
      isShownPhoneError = true;
    });
  }
  @override
  void showErrorMsg(String? error) {
    setState(() {
      errorMsg = error;
      isShownIDError = true;
    });
  }

  @override
  void showSuccessMsgCode(String? msg) {}
}
