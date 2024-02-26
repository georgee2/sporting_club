import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/LoginResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/Update_membership/update/update_step_three.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/my_activities/my_activities.dart';
import 'package:sporting_club/ui/real_estate/real_estate_reservations.dart';
import 'package:sporting_club/utilities/local_settings.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile>
    implements LoginResponseListener, ReloadTripsDelagate {
  LocalSettings _localSettings = LocalSettings();
  User user = User();
  UserNetwork _userNetwork = UserNetwork();

  @override
  void initState() {
    _userNetwork.getProfile(this);
    setUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Align(
              child: Text(
                'الحساب الشخصي',
                textAlign: TextAlign.right,
              ),
              alignment: Alignment.centerRight,
            ),
            actions: <Widget>[
              new IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
            leading: new Container(),
            // <-- ELEVATION ZEROED
            automaticallyImplyLeading: true,
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
    String name = "";
    if (user.first_name != null) {
      name = "${user.first_name} ";
    }
    if (user.last_name != null) {
      name = name + (user.last_name ?? "");
    }
    if (user.user_name != null) {
      name = user.user_name ?? "";
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 35, bottom: 10),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.network(
                    // Base64Decoder().convert(user.user_photo ?? ""),
                    user.user_photo ?? "",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (c, t, o) {
                      return Image.asset(
                        'assets/profile_ic_avatar.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  )),
            ),
            Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            SizedBox(
              height: 30,
            ),
            _buildProfileInfo(),
            SizedBox(
              height: 30,
            ),
            _buildProfileInterests(),
            SizedBox(
              height: 15,
            ),
            _buildRealEstateReservations(),
            SizedBox(
              height: 15,
            ),
            _buildPMyActivitiesButton(),
            SizedBox(
              height: 15,
            ),
            _buildupdateProfile(),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width - 30,
      padding: EdgeInsets.only(bottom: 30, right: 15, left: 15, top: 10),
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
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'رقم العضوية',
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
          ),
          Text(
            user.membership_no != null ? user.membership_no.toString() : "",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'الهاتف',
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
          ),
          Text(
            user.phone ?? "",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
//          SizedBox(
//            height: 25,
//          ),
//          Text(
//            'البريد الالكتروني',
//            style:
//                TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
//          ),
//          Text(
//            user.user_email != null ? user.user_email : "",
//            style: TextStyle(color: Colors.black, fontSize: 16),
//          ),
        ],
      ),
    );
  }

  Widget _buildProfileInterests() {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: width - 30,
        padding: EdgeInsets.only(bottom: 15, right: 15, left: 15, top: 15),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              child: Image.asset(
                'assets/left_ic.png',
                width: 8,
                height: 25,
                fit: BoxFit.fitWidth,
              ),
              alignment: Alignment.centerLeft,
            ),
            Align(
              child: Container(
                child: Text(
                  'تعديل الاهتمامات',
                  style: TextStyle(fontSize: 15, color: Color(0xffff5c46)),
                  textAlign: TextAlign.right,
                ),
                width: width - 100,
              ),
              alignment: Alignment.centerRight,
            ),
            SizedBox(
              width: 10,
            ),
            Align(
              child: Image.asset(
                'assets/edit_ic.png',
                width: 20,
                height: 20,
                fit: BoxFit.fitWidth,
              ),
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Interests(true, null, 0))),
    );
  }

  Widget _buildupdateProfile() {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
        child: Container(
          width: width - 30,
          padding: EdgeInsets.only(bottom: 15, right: 15, left: 15, top: 15),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Image.asset(
                  'assets/left_ic.png',
                  width: 8,
                  height: 25,
                  fit: BoxFit.fitWidth,
                ),
                alignment: Alignment.centerLeft,
              ),
              Align(
                child: Container(
                  child: Text(
                    'تحديث البيانات ',
                    style: TextStyle(fontSize: 15, color: Color(0xffff5c46)),
                    textAlign: TextAlign.right,
                  ),
                  width: width - 100,
                ),
                alignment: Alignment.centerRight,
              ),
              SizedBox(
                width: 10,
              ),
              Align(
                child: Image.asset(
                  'assets/edit_ic.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.fitWidth,
                ),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
        onTap: () {
          UserData userData = UserData(
              name: user.user_name,
              email: user.user_email,
              phone: user.phone,
              member_id: user.membership_no.toString(),
              national_id: user.national_id,
              birthdate: "");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => UpdateMembershipStepThree(
                      userData: userData,
                      userMembership: user.membership_no.toString(),
                      reloadTripsDelagate: this)));
        });
  }

  Widget _buildRealEstateReservations() {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
        child: Container(
          width: width - 30,
          padding: EdgeInsets.only(bottom: 15, right: 15, left: 15, top: 15),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Image.asset(
                  'assets/left_ic.png',
                  width: 8,
                  height: 25,
                  fit: BoxFit.fitWidth,
                ),
                alignment: Alignment.centerLeft,
              ),
              Align(
                child: Container(
                  child: Text(
                    'حُجزات الشهر العقاري',
                    style: TextStyle(fontSize: 15, color: Color(0xffff5c46)),
                    textAlign: TextAlign.right,
                  ),
                  width: width - 100,
                ),
                alignment: Alignment.centerRight,
              ),
              SizedBox(
                width: 10,
              ),
              Align(
                child: Image.asset(
                  'assets/building_ic.png',
                  width: 20,
                  height: 20,
                  color: Color(0xffff5c46),
                  fit: BoxFit.fitWidth,
                ),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      RealEstateReservationsScreen()));
        });
  }

  Widget _buildPMyActivitiesButton() {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: width - 30,
        padding: EdgeInsets.only(bottom: 15, right: 15, left: 15, top: 15),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              child: Image.asset(
                'assets/left_ic.png',
                width: 8,
                height: 25,
                fit: BoxFit.fitWidth,
              ),
              alignment: Alignment.centerLeft,
            ),
            Align(
              child: Container(
                child: Text(
                  'نشاطاتي',
                  style: TextStyle(fontSize: 15, color: Color(0xffff5c46)),
                  textAlign: TextAlign.right,
                ),
                width: width - 100,
              ),
              alignment: Alignment.centerRight,
            ),
            SizedBox(
              width: 10,
            ),
            Align(
              child: Image.asset(
                'assets/activities_ic.png',
                width: 20,
                height: 20,
                color: Color(0xffff5c46),
                fit: BoxFit.fitWidth,
              ),
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MyActivities(false))),
    );
  }

  void setUserData() {
    if (LocalSettings.user != null) {
      setState(() {
        this.user = LocalSettings.user ?? User();
      });
    } else {}
  }

  bool _isloading = false;

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
  void showAuthError() {}

  @override
  void showSuccessLogin(LoginData? data) {
    if (data?.user != null) {
      // _localSettings.setUser(data?.user ?? User());
      // LocalSettings.user = data?.user;
      setState(() {
        this.user = data?.user ?? User();
      });
    }
  }

  @override
  void reloadTripsAfterBooking(User? user) {
    print("reloadiiiiiiiiii");
    // if (LocalSettings.user != null) {
    setState(() {
      print("phone${user?.phone}");
      this.user = user ?? User();
    });
    // }
  }
}
