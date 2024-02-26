import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/login/verify_login.dart';
import 'package:sporting_club/ui/update_info/update_info_firstStep.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DoctorLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DoctorLoginState();
  }
}

class DoctorLoginState extends State<DoctorLogin>
    implements BasicResponseListener, LoginResponseListener {
  final _phonecontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool _isValidPhone = true;
  bool _isValidPassword = true;
  String _phoneErrorValue = "";
  String _passwordErrorValue = "";

  UserNetwork userNetwork = UserNetwork();
  bool _isloading = false;
  bool send_phone = false;
  bool send_email = false;

  @override
  void initState() {
    print('initState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      child: Stack(
        children: [
          Container(
            color: Color(0xff00701A),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 22, left: 25, right: 25),
                    child: _buildContent(),
                  ),
                  _buildHeader()
                ],
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
                alignment: Alignment.center,
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
                    'تسجيل للطوارئ',
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xff76d275),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 5.0),
              ),

//            SizedBox(
//              height: 70,
//            ),
              _buildPhoneField(),
              _buildPasswordField(),
              SizedBox(
                height: 30,
              ),
              _buildSubmitButton(),

              isLoginError ? _buildErrorContent() : SizedBox(),
              //  Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return  Positioned(
    right: 10,
      top: 10,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: IconButton(
          icon: new Image.asset('assets/back_white.png'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          child: TextField(
            controller: _phonecontroller,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'رقم التليفون',
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
        Visibility(
          child: Container(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              _phoneErrorValue,
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ),
          visible: !_isValidPhone,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          child: TextField(
            controller: _passwordcontroller,
            textAlign: TextAlign.right,
            obscureText: true,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'كلمة المرور',
            ),
            keyboardType: TextInputType.text,
            keyboardAppearance: Brightness.light,
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
        Visibility(
          child: Container(
            padding: EdgeInsets.only(right: 2),
            child: Text(
              _passwordErrorValue,
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ),
          visible: !_isValidPassword,
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
                          UpdateInfoFirstStep(_phonecontroller.text)));
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
    if (_phonecontroller.text.isEmpty) {
      setState(() {
        _phoneErrorValue = " برجاء إدخال رقم التليفون";
        _isValidPhone = false;
      });
    } else{
      setState(() {
        _isValidPhone = true;
      });
    } if (_passwordcontroller.text.isEmpty) {
      setState(() {
        _passwordErrorValue = "برجاء إدخال كلمة المرور";
        _isValidPassword = false;
      });
    }else{
      _isValidPassword = true;

    }
    if(_phonecontroller.text.isNotEmpty&&_passwordcontroller.text.isNotEmpty) {
      setState(() {
        _isValidPhone = true;
        _isValidPassword = true;
        isLoginError = false;
      });
      userNetwork.loginByDoctor(
          _phonecontroller.text, _passwordcontroller.text, this);
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

  LocalSettings _localSettings = LocalSettings();

  @override
  void showSuccessLogin(LoginData? data) {
    bool isOldUser = false;
    // _localSettings.setLoginData(data?.copyWith(isDoctor: true) ?? LoginData());
    // LocalSettings.loginData =data?.copyWith(isDoctor: true) ?? LoginData();

    if (data?.token != null) {
      _localSettings.setToken(data?.token ?? "");
      LocalSettings.token = "Bearer ${data?.token}";
      print('token: ${data?.token}');
    }
    if (data?.refresh_token != null) {
      _localSettings.setRefreshToken(data?.refresh_token ?? "");
      LocalSettings.refreshToken = data?.refresh_token ?? "";
    }
    if (data?.user != null) {
      _localSettings.setUser(data?.user?.copyWith(isDoctor: true) ?? User());
      LocalSettings.user = data?.user?.copyWith(isDoctor: true) ;
      if (data?.user?.user_login_before != null) {
        if (data?.user?.user_login_before == "1") {
          isOldUser = true;
        }
      }
    }

    if (data?.interests != null) {
      _localSettings.setInterests(data?.interests ?? []);
      LocalSettings.interests = data?.interests ?? [];
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        (Route<dynamic> route) => false);
  }

  bool isLoginError = false;

  @override
  void showLoginError(String? error) {
    setState(() {
      isLoginError = true;
    });
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
  void showSuccess(String? error) {
    // TODO: implement showSuccess
  }
}
