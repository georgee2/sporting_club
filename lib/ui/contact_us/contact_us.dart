import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/repositories/info_network.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ContactUs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactUsState();
  }
}

class ContactUsState extends State<ContactUs> implements BasicResponseListener {
  User? _user = User();
  LocalSettings _localSettings = LocalSettings();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isValidName = true;
  bool _isValidEmail = true;
  bool _isValidAddress = true;
  bool isValidContent = true;

  String _emailErrorMsg = 'يرجى إضافة بريدك الإلكتروني';
  Validation validation = Validation();
  InfoNetwork _infoNetwork = InfoNetwork();

  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    if (LocalSettings.user != null) {
      this._user = LocalSettings.user;
      _setUserInitialValue();
    } else {
      _localSettings.getUser().then((user) {
        setState(() {
          this._user = user;
          _setUserInitialValue();
        });
      });
    }
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
              'أتصل بنا',
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          backgroundColor: Color(0xfff9f9f9),
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
    return SingleChildScrollView(
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFieldTitle('الاسم'),
            _buildInputField('الاسم', _nameController, TextInputType.text),
            !_isValidName ? _buildFieldError('يرجى إضافة اسمك ') : SizedBox(),
            _buildFieldTitle('البريد الالكتروني'),
            _buildEmailInputField('البريد الالكتروني', _emailController,
                TextInputType.emailAddress),
            !_isValidEmail ? _buildFieldError(_emailErrorMsg) : SizedBox(),
            _buildFieldTitle('العنوان'),
            _buildInputField('العنوان', _addressController, TextInputType.text),
            !_isValidAddress
                ? _buildFieldError('يرجى إضافة عنوانك')
                : SizedBox(),
            _buildFieldTitle('اكتب رسالتك'),
            _buildMessageField(),
            !isValidContent
                ? _buildFieldError('يرجى إضافة رسالتك')
                : SizedBox(),
            _buildSubmitButton(),
          ],
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
      padding: EdgeInsets.only(right: 15, top: 0, bottom: 5),
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
      padding: EdgeInsets.only(right: 15, top: 5, bottom: 10, left: 15),
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
                EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 12),
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
        height: 50,
      ),
    );
  }

  Widget _buildEmailInputField(
      String title, TextEditingController controller, TextInputType type) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, top: 5, bottom: 10, left: 15),
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
            EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 12),
            hintText: title,
          ),
          keyboardType: type,
          keyboardAppearance: Brightness.light,
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
        height: 50,
      ),
    );
  }

  Widget _buildMessageField() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, top: 5, bottom: 10, left: 15),
      child: Container(
        child: TextField(
          controller: _contentController,
          style: TextStyle(fontSize: 16, color: Colors.black),
          maxLines: 5,
          // textInputAction: TextInputAction.newline,
          decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 12),
            hintText: 'اكتب رسالتك',
          ),
          keyboardType: TextInputType.text,
          keyboardAppearance: Brightness.light,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(225),
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
        height: 100,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(right: 15, top: 20, bottom: 15, left: 15),
        child: Container(
          child: Center(
            child: Text(
              'اتصل بنا',
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
              borderRadius: new BorderRadius.all(Radius.circular(10))),
          height: 50,
        ),
      ),
      onTap: _submitAction,
    );
  }

  void _setUserInitialValue() {
    String name = "";
    if (_user?.first_name != null) {
      name =   "${_user?.first_name} ";
    }
    if (_user?.last_name != null) {
      name =   "$name${_user?.last_name}";
    }
    _nameController.text = name;

    _emailController.text = _user?.user_email??"";
  }

  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (validateFields()) {
      _infoNetwork.contactUs(_nameController.text, _emailController.text,
          _addressController.text, _contentController.text, this);
    }
  }

  bool validateFields() {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() {
        _isValidName = false;
      });
      isValid = false;
    } else {
      setState(() {
        _isValidName = true;
      });
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _isValidEmail = false;
        _emailErrorMsg = 'يرجى إضافة بريدك الإلكتروني';
      });
      isValid = false;
    } else {
      if (validation.isEmail(_emailController.text)) {
        setState(() {
          _isValidEmail = true;
        });
      } else {
        setState(() {
          _isValidEmail = false;
          _emailErrorMsg = 'يرجى إضافة بريدك الإلكتروني صحيح';
        });
        isValid = false;
      }
    }

    if (_addressController.text.isEmpty) {
      setState(() {
        _isValidAddress = false;
      });
      isValid = false;
    } else {
      setState(() {
        _isValidAddress = true;
      });
    }

    if (_contentController.text.isEmpty) {
      setState(() {
        isValidContent = false;
      });
      isValid = false;
    } else {
      setState(() {
        isValidContent = true;
      });
    }

    return isValid;
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
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void showSuccess(String? error) {
    Fluttertoast.showToast(msg:'تم تسجيل رسالتك بنجاح', toastLength: Toast.LENGTH_LONG);
    Navigator.of(context).pop(null);
  }
  @override
  void showLoginError(String? error) {
  }
}
