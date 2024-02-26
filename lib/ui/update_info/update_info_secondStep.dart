import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/login/verify_login.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UpdateInfoSecondStep extends StatefulWidget {
  String _memberIdValue = "";
  String _nationalIdValue = "";


  UpdateInfoSecondStep(this._memberIdValue, this._nationalIdValue);

  @override
  State<StatefulWidget> createState() {
    return UpdateInfoSecondStepState();
  }
}

class UpdateInfoSecondStepState extends State<UpdateInfoSecondStep> implements BasicResponseListener {
  final _controller = TextEditingController();
  bool _isValid = true;
  String _errorValue = "";

  UserNetwork userNetwork = UserNetwork();
  bool _isloading = false;
  Image myImage= Image.asset('assets/shape.png');

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
    myImage= Image.asset('assets/shape.png');
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
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Color(0xff43a047) , Color(0xff00701a)])),
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
                'الخطوة الثانية',
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
            _buildInputField(),
            SizedBox(
              height: 30,
            ),
            _buildSubmitButton(),
            SizedBox(
              height: 10,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      children: <Widget>[
        Align(
          child: Container(
            child: Text(
              'قم بادخال رقم الهاتف ',
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
        Container(
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: 'رقم الهاتف',
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
            'التاكيد',
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
                  color:Color.fromRGBO(0, 112, 26, 1),
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
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(5))),
      ),
      onTap: _submitAction,
    );
  }
  void _submitAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isValid = true;
      });
      userNetwork.updatePhone(widget._nationalIdValue, _controller.text, this);
    } else {
      setState(() {
        _errorValue = "برجاء إدخال رقم الهاتف";
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
    // TODO: implement showAuthError
  }

  @override
  void showSuccess(String? successMsg) {

    Fluttertoast.showToast(msg:'سيتم إرسال رسالة نصية بكود التفعيل ', toastLength: Toast.LENGTH_LONG);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => VerifyLogin(widget._memberIdValue , successMsg??"" , false, true)));
  }
  bool isLoginError=false;
  @override
  void showLoginError(String? error) {
    setState(() {
      isLoginError=true;
    });
  }
}
