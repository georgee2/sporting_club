import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/login/verify_login.dart';
import 'package:sporting_club/ui/update_info/update_info_firstStep.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'doctor_login.dart';

class Login extends StatefulWidget {
  final String? membershipId;
  final String? type;
  final String? postId;
  final bool? from_branch;

  const Login(
      {Key? key, this.membershipId, this.type, this.postId, this.from_branch})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login>
    implements BasicResponseListener, RegisterMembershipListener {
  final _controller = TextEditingController();
  bool _isValid = true;
  String _errorValue = "";

  UserNetwork userNetwork = UserNetwork();
  bool _isloading = false;
  Image myImage = Image.asset('assets/shape.png');
  bool send_phone = false;
  bool send_email = false;

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
    myImage = Image.asset('assets/shape.png');
    _controller.value = TextEditingValue(
        text:
            widget.membershipId == null ? "" : widget.membershipId.toString());
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      child: Stack(
        children: [
          Container(
            color: Color(0xff43a047),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/green_backgound.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: myImage.image,
                fit: BoxFit.fill,
              ),
            ),
            height: 310,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,

            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 22, left: 25, right: 25),
                child: _buildContent(),
              ),
            ),
            bottomNavigationBar: _buildGuestLink(),

//            SafeArea(
//              child: Stack(
//                children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.all(25),
//                      child: _buildContent(),
//                    ),
//
////                  Align(
////                    alignment: Alignment.bottomCenter,
////                    child: Padding(
////                      padding: const EdgeInsets.symmetric(vertical: 15),
////                      child: GestureDetector(
////                        onTap: () {
////                          Navigator.pushAndRemoveUntil(
////                              context,
////                              MaterialPageRoute(builder: (BuildContext context) => Home()),
////                                  (Route<dynamic> route) => false);
////
////                        },
////                        child: Text(
////                          'الدخول كضيف وتخطي التسجيل',
////                          style: TextStyle(
////                              color: Colors.white,
////                              fontSize: 14,
////                              fontWeight: FontWeight.w700,
////                              decorationThickness: 2,
////                              decoration: TextDecoration.underline),
////                        ),
////
////                      ),
////                    ),
////                  ),
//
//                  Align(
//                    alignment: Alignment.bottomCenter,
//                    child:
//                    Column(
//    mainAxisSize: MainAxisSize.max,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//
//                        mainAxisAlignment: MainAxisAlignment.end,
//
//                        children: <Widget>[
//
//                       GestureDetector(
//                        onTap: () {
//                          Navigator.pushAndRemoveUntil(
//                              context,
//                              MaterialPageRoute(builder: (BuildContext context) => Home()),
//                                  (Route<dynamic> route) => false);
//
//                        },
//                        child:Container(
//                          margin: const EdgeInsets.all(15.0),
//                          padding: const EdgeInsets.all(1.0),                          decoration: BoxDecoration(
//                          border: Border(
//                              bottom: BorderSide(
//                                  width: 1.0,
//                              color: Colors.white,
//
//                              ),
//                            ),
//                          ),
//                          child: Text(
//                            'الدخول كضيف وتخطي التسجيل',
//                            style: TextStyle(
//                                color: Colors.white,
//                                fontSize: 14,
//                                fontWeight: FontWeight.w700,
//                               ),
//                          ),
//                        ),
//                      ),
//
//
//                        ]
//                    ),
//                  ),
//    ],
//              ),
//            ),
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
    double height = MediaQuery.of(context).size.height - 50;

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
        child: SizedBox(
          height: height,
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
                alignment: Alignment.centerRight,
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Align(
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xff76d275),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  alignment: Alignment.centerRight,
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 5.0),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Align(
                  child: Text(
                    'قم بالتسجيل عن طريق رقم العضوية',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  alignment: Alignment.centerRight,
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              ),
//            SizedBox(
//              height: 70,
//            ),
              _buildInputField(),

              SizedBox(
                height: 30,
              ),
              _buildSubmitButton(),

              isLoginError ? _buildErrorContent() : SizedBox(),
              //  Spacer(),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  DoctorLogin()));
                    },
                    child: Container(
                      child: Text(
                        "تسجيل للطوارئ",
                        style: TextStyle(
                          shadows: [
                            Shadow(color: Colors.white, offset: Offset(0, -2))
                          ],
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          decorationThickness: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Image.asset("assets/user_doctor_ic.png"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestLink() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Home()),
                  (Route<dynamic> route) => false);
            },
            child: Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
              child: Text(
                'الدخول كضيف وتخطي التسجيل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ]);
  }

  Widget _buildInputField() {
    return Column(
      children: <Widget>[
        Align(
          child: Container(
            child: Text(
              'ادخل رقم العضوية',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            margin: EdgeInsets.only(left: 25, top: 70, right: 15),
          ),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'رقم العضوية',
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
            ),
            visible: !_isValid,
          ),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      child: Container(
        child: Center(
          child: Text(
            'التسجيل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10, top: 10),
        decoration: new BoxDecoration(
            color: Color.fromRGBO(255, 92, 70, 1),
            borderRadius: new BorderRadius.all(Radius.circular(5))),
        height: 50,
      ),
      onTap: _submitAction,
    );
  }

  Widget _buildErrorContent() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'رقم الهاتف/البريد الالكتروني غير موجود',
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UpdateInfoFirstStep(_controller.text)));
            },
            child: Text(
              'يرجى تحديث المعلومات',
              style: TextStyle(
                  color: Color(0xfff12b10),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decorationThickness: 2,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 12, top: 12),
      margin: EdgeInsets.only(bottom: 20, top: 10),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isValid = true;
        isLoginError = false;
      });
      userNetwork.checkMemberidInLogin(_controller.text, this);
    } else {
      setState(() {
        _errorValue = "برجاء إدخال رقم العضوية";
        _isValid = false;
      });
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
    Fluttertoast.showToast(
        msg: "حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg: msg ?? "", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    setState(() {
      isLoginError = true;
    });
    // TODO: implement showAuthError
  }

  @override
  void showSuccess(String? successMsg) {
//    Fluttertoast.showToast(msg:'سيتم إرسال رسالة نصية بكود التفعيل ', context,
//        duration: Toast.LENGTH_LONG);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => VerifyLogin(
                _controller.text, successMsg ?? "", send_phone, send_email,
                type: widget.type,
                postId: widget.postId,
                from_branch: widget.from_branch)));
  }

  bool isLoginError = false;

  @override
  void showLoginError(String? error) {
    setState(() {
      isLoginError = true;
    });
  }

  void showConfirmationDialoug(String msg) {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  child: IconButton(
                    icon: new Image.asset('assets/close_green_ic.png'),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Text("حدد اختيارا",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color.fromRGBO(67, 160, 71, 1))),
                SizedBox(
                  height: 10,
                ),
                Text("إختر طريقة التحقق التي ترغب بها",
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color.fromRGBO(100, 100, 100, 1))),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 20),
                      child: Container(
                        width: 160,
                        height: 50,
                        child: Center(
                          child: Text(
                            'البريد الالكتروني',
                            style: TextStyle(
                                fontSize: 16,
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
                      Navigator.of(context).pop();
                      setState(() {
                        _isValid = true;
                        isLoginError = false;
                      });
                      send_phone = false;
                      send_email = true;

                      userNetwork.loginMessageUser(
                          _controller.text, send_phone, send_email, this);
                      // _navigateToNextAction();
                    }),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 20),
                      child: Container(
                        width: 160,
                        height: 50,
                        child: Center(
                          child: Text(
                            'رسالة قصيرة',
                            style: TextStyle(
                                fontSize: 16,
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
                      Navigator.of(context).pop();
                      setState(() {
                        _isValid = true;
                        isLoginError = false;
                      });
                      send_phone = true;
                      send_email = false;
                      userNetwork.loginMessageUser(
                          _controller.text, send_phone, send_email, this);
                      // _navigateToNextAction();
                    }),

                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(15.0),
                      //  padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Color.fromRGBO(67, 160, 71, 1),
                          ),
                        ),
                      ),

                      child: Text(
                        'تحديث البيانات',
                        style: TextStyle(
                          color: Color.fromRGBO(67, 160, 71, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  UpdateInfoFirstStep(_controller.text)));
                    }),
//                GestureDetector(
//                  onTap: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (BuildContext context) =>
//                                UpdateInfoFirstStep(_controller.text)));
//                  },
//                  child: Text(
//                    'يرجى تحديث المعلومات',
//                    style: TextStyle(
//                        color: Color.fromRGBO(67, 160, 71, 1),
//                        fontSize: 15,
//                        fontWeight: FontWeight.w700,
//                        decorationThickness: 2,
//                        decoration: TextDecoration.underline),
//                  ),
//                ),
              ],
            ),
          ),
          height: 50,
        );
      },
    );
  }

  void showConfirmationDialoug1(String msg) {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  child: IconButton(
                    icon: new Image.asset('assets/close_green_ic.png'),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Text("رسالة التأكيد",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color.fromRGBO(67, 160, 71, 1))),
                SizedBox(
                  height: 10,
                ),
                Text(msg,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color.fromRGBO(100, 100, 100, 1))),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 20),
                      child: Container(
                        width: 160,
                        height: 50,
                        child: Center(
                          child: Text(
                            'تأكيد الارسال',
                            style: TextStyle(
                                fontSize: 16,
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
                      setState(() {
                        _isValid = true;
                        isLoginError = false;
                      });
                      Navigator.of(context).pop(null);
                      userNetwork.loginUser(
                          _controller.text, send_phone, send_email, this);
                      // _navigateToNextAction();
                    }),

                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(15.0),
                      //  padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Color.fromRGBO(67, 160, 71, 1),
                          ),
                        ),
                      ),

                      child: Text(
                        'تحديث البيانات',
                        style: TextStyle(
                          color: Color.fromRGBO(67, 160, 71, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  UpdateInfoFirstStep(_controller.text)));
                    }),
//                GestureDetector(
//                  onTap: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (BuildContext context) =>
//                                UpdateInfoFirstStep(_controller.text)));
//                  },
//                  child: Text(
//                    'يرجى تحديث المعلومات',
//                    style: TextStyle(
//                        color: Color.fromRGBO(67, 160, 71, 1),
//                        fontSize: 15,
//                        fontWeight: FontWeight.w700,
//                        decorationThickness: 2,
//                        decoration: TextDecoration.underline),
//                  ),
//                ),
              ],
            ),
          ),
          height: 50,
        );
      },
    );
  }

  @override
  void showEmailError({String? errorMsg}) {
    // TODO: implement showEmailError
  }

  @override
  void showMemberShipIDError() {
    setState(() {
      isLoginError = true;
    });
    // TODO: implement showMemberShipIDError
  }

  @override
  void showPhoneError(String? error) {
    // TODO: implement showPhoneError
  }

  @override
  void showSuccessID(String? msg) {
    showConfirmationDialoug(msg ?? "");
    // TODO: implement showSuccessID
  }

  @override
  void showSuccessMsgCode(String? msg) {
    //Navigator.of(context).pop(null);
    showConfirmationDialoug1(msg ?? "");
  }

  @override
  void showErrorMsg(String? error) {}
}
