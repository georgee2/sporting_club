import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/emergency.dart';
import 'package:sporting_club/data/model/emergency_data.dart';
import 'package:sporting_club/delegates/close_panel_delegate.dart';
import 'package:sporting_club/network/listeners/MoreResponseListener.dart';
import 'package:sporting_club/network/repositories/info_network.dart';
import 'package:sporting_club/network/repositories/notifications_network.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/complaints/complaints_list.dart';
import 'package:sporting_club/ui/contact_us/contact_us.dart';
import 'package:sporting_club/ui/contacting_info/contacting_info.dart';
import 'package:sporting_club/ui/emergency_numbers/emergency_numbers.dart';
import 'package:sporting_club/ui/events/events_list.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/ui/matches/matches_list.dart';
import 'package:sporting_club/ui/news/news_list.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/notifications/notifications_settings.dart';
import 'package:sporting_club/ui/offers_services/offers__list.dart';
import 'package:sporting_club/ui/offers_services/offers_services_list.dart';
import 'package:sporting_club/ui/profile/profile.dart';
import 'package:sporting_club/ui/restaurants/restaurants.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';

import '../sos/screens/emergency_categories.dart';

class More extends StatefulWidget {
  ClosePanelDeleagte? closePanelDeleagte;
  bool isFullMore;
  Color backgroundColor;

  More(this.closePanelDeleagte, this.isFullMore, this.backgroundColor);

  @override
  State<StatefulWidget> createState() {
    return MoreState(this.closePanelDeleagte, this.isFullMore);
  }
}

class MoreState extends State<More> implements MoreResponseListener {
  ClosePanelDeleagte? closePanelDeleagte;
  bool isFullMore;
  bool _isloading = false;
  InfoNetwork _infoNetwork = InfoNetwork();
  UserNetwork _userNetwork = UserNetwork();

  LocalSettings _localSettings = LocalSettings();
  String _version = "";
  String buildNumber = "";

  MoreState(this.closePanelDeleagte, this.isFullMore);
  bool isLoggedInMember = false;
  bool isLoggedInDoctor = false;
  @override
  void initState() {
    super.initState();
    setAppVersion();
    isLoggedInMember = (LocalSettings.token != null &&
        (LocalSettings.user?.isMember ?? false));
    isLoggedInDoctor = (LocalSettings.token != null &&
        !(LocalSettings.user?.isMember ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: widget.backgroundColor,
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        // isFullMore
        //     ? SizedBox()
        //     : Padding(
        //         padding: EdgeInsets.only(top: 0),
        //         child: Container(
        //           color: Colors.white,
        //           width: width,
        //           height: height - 250,
        //         ),
        //       ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // isFullMore
                //     ? SizedBox()
                //     : Container(
                //         color: Colors.white,
                //         height: 20,
                //       ),

//                 Container(
//                   color: Colors.white,
//                   child: _buildMoreSettings(),
//                   margin: EdgeInsets.only(left: 0, top: 20, bottom: 0),
//
// //              child: _buildFullSettings(),
//                 ),
                _buildMoreSettings()
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMoreSettings() {
    bool isLoggedin = false;
    if (LocalSettings.token != null) {
      isLoggedin = true;
    }
    return Column(
      children: <Widget>[
        isFullMore ? _buildFullSettings() : SizedBox(),
        // isFullMore
        //     ? SizedBox()
        //     : SizedBox(
        //         height: 5,
        //       ),

        //
        // GestureDetector(
        //   child: _buildItem('assets/offers.png', 'العروض'),
        //   onTap: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (BuildContext context) => OffersList(true))),
        // ),
        isLoggedInMember && !isFullMore
            ? _buildUserSettings()
            : SizedBox(
                height: 20,
              ),
        isLoggedInDoctor && !isFullMore
            ? _buildDoctorUserCategories()
            : SizedBox(
                height: 0,
              ),
        SizedBox(
          height: 5,
        ),
        isFullMore
            ? Divider(
                height: 1,
              )
            : SizedBox(),
        // isFullMore ? _buildTilte('الإعدادات') : SizedBox(),
        _buildTilte('الإعدادات'),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/complaints_ic.png', 'الشكاوى والاراء'),
            onTap: () {
              isLoggedInMember
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ComplaintsList()))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: _buildItem('assets/contactus_ic.png', 'أتصل بنا'),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ContactUs())),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: _buildItem('assets/contactus_ic-1.png', 'وسائل التواصل'),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ContactingInfo())),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/notification_ic.png', 'ضبط الاشعارات'),
            onTap: () {
              isLoggedInMember
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NotificationsSettings()))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
//        _buildItem('assets/emrg_ic.png', 'أرقام الطوارئ'),
        GestureDetector(
          child: _buildItem('assets/emrg_ic.png', 'أرقام الطوارئ'),
          onTap: () => _infoNetwork.getEmergencyNumbers(this),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/profile_ic.png', 'الحساب الشخصي'),
            onTap: () {
              isLoggedInMember
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Profile()))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: LocalSettings.token != null
              ? _buildItem('assets/logout_ic.png', 'تسجيل الخروج')
              : _buildItem('assets/logout_ic.png', 'تسجيل الدخول'),
          onTap: () {
            if (LocalSettings.token == null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Login()),
                  (Route<dynamic> route) => false);
            } else {
              _showLogoutDialog();
            }
          },
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 52),
            child: Text(
              ' نسخة التطبيق  ' + _version,
              style: TextStyle(fontSize: 15),
            ),
          ),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  Future<String?> _asyncEmergancyDialog(
      BuildContext context, Emergency emergency) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return EmergencyNumbers(emergency);
      },
    );
  }

  Widget _buildFullSettings() {
    return Column(
      children: <Widget>[
        _buildTilte('الأقسام'),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/events.png', 'الفعاليات'),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => EventsList(true)))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/trips.png', 'الرحلات'),
//          onTap: () => Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (BuildContext context) => TripsList())),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: RouteSettings(name: 'TripsWeb'),
                        builder: (context) =>
                            TripsList(false, true), // TripsWeb(),
                        //TripsList(false,true),
                      ),
                    )
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/services_ic.png', 'خدمات نادي سبورتنج'),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              OffersServicesList(false)))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: _buildItem('assets/restaurants.png', 'المطاعم'),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => RestaurantsList())),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget _buildUserSettings() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              // color: Color(0xfff9f9f9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Align(
                    child: Container(
                      child: Text(
                        "الأقسام",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 0, bottom: 8),
              child: GestureDetector(
                child: Container(
                  child: Align(
                    child: Image.asset('assets/close_ic.png'),
                    alignment: Alignment.centerLeft,
                  ),
                  height: 25,
                ),
                onTap: () {
                  if (closePanelDeleagte != null) {
                    closePanelDeleagte?.closePanel();
                  }
                },
              ),
            ),
          ],
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/news_ic.png', 'الأخبـار'),
            onTap: () {
              LocalSettings.newsId = null;
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NewsList(false, 0)))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/events.png', 'الفعاليات'),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => EventsList(false)))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/trips.png', 'الرحلات'),
//          onTap: () => Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (BuildContext context) => TripsList())),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.of(context).push(
                      // MaterialPageRoute(
                      //     settings: RouteSettings(
                      //         name: 'TripsWep'),
                      //     builder: (context) =>
                      //         TripsWeb(),
                      //   ),
                      MaterialPageRoute(
                        settings: RouteSettings(name: 'TripsList'),
                        builder: (context) => TripsList(false, false),
                      ),
                    )
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/results_ic.png', 'النتائج'),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MatchesList(false)))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        // Divider(
        //   height: 1,
        // ),
        // SizedBox(
        //   height: 5,
        // ),
        // GestureDetector(
        //   child: _buildItem('assets/restaurants.png', 'المطاعم'),
        //   onTap: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (BuildContext context) => RestaurantsList())),
        // ),

        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/emergency_home_ic.png', 'طوارئ'),
            onTap: () {
              (LocalSettings.token != null)
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EmergencyCategoriesScreen()))
                  : showLoginView();
            }),

        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: _buildItem('assets/admin_notif_ic.png', 'الاشعارات'),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NotificationsList())),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget _buildDoctorUserCategories() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              // color: Color(0xfff9f9f9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Align(
                    child: Container(
                      child: Text(
                        "الأقسام",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 0, bottom: 8),
              child: GestureDetector(
                child: Container(
                  child: Align(
                    child: Image.asset('assets/close_ic.png'),
                    alignment: Alignment.centerLeft,
                  ),
                  height: 25,
                ),
                onTap: () {
                  if (closePanelDeleagte != null) {
                    closePanelDeleagte?.closePanel();
                  }
                },
              ),
            ),
          ],
        ),
        // Divider(
        //   height: 1,
        // ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
            child: _buildItem('assets/emergency_home_ic.png', 'طوارئ'),
            onTap: () {
              LocalSettings.token != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EmergencyCategoriesScreen()))
                  : showLoginView();
            }),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          child: _buildItem('assets/admin_notif_ic.png', 'الاشعارات'),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NotificationsList())),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget _buildItem(String imageName, String title) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            child: Image.asset(
              imageName,
              width: 28,
              height: 28,
//              fit: BoxFit.fill,
            ),
            alignment: Alignment.centerRight,
          ),
          SizedBox(
            width: 10,
          ),
          Align(
            child: Container(
              child: Text(
                title,
                style: TextStyle(fontSize: 15),
              ),
              width: width - 80,
            ),
            alignment: Alignment.centerRight,
          ),
          Align(
            child: Image.asset(
              'assets/left_ic.png',
              width: 8,
              height: 25,
              fit: BoxFit.fitWidth,
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }

  Widget _buildTilte(String title) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.only(top: 15, bottom: 15),
      color: Color(0xfff9f9f9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Align(
            child: Container(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
//              width: width - 40,
            ),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Container(
          child: AlertDialog(
            title: Align(
              child: Text(
                'تسجيل الخروج',
              ),
              alignment: Alignment.centerRight,
            ),
            content:
//          Align(
//            child:
                new Text(
              'هل تريد الخروج من التطبيق ؟ لن تستقبل اشعارات بخروجك من التطبيق',
              textAlign: TextAlign.right,
            ),
//            alignment: Alignment.centerRight,
//          ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "لا",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "نعم",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
              ),
            ],
          ),
          height: 50,
        );
      },
    );
  }

  void _logout() {
    print('logout');
//    _localSettings.removeSession();
//    Navigator.pushAndRemoveUntil(
//        context,
//        MaterialPageRoute(builder: (BuildContext context) => Login()),
//        (Route<dynamic> route) => false);
    print("player_id${LocalSettings.playerId}");

    NotificationsNetwork notificationsNetwork = NotificationsNetwork();
    notificationsNetwork.unsubscribeNotification(this);
  }

  void setAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
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
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void setData(EmergencyData? data) {
    if (data?.emergency != null) {
      _asyncEmergancyDialog(context, data?.emergency ?? Emergency());
    }
  }

  @override
  void showLogoutSuccess() {
    _localSettings.removeSession();
    LocalSettings.playerId = "";
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        (Route<dynamic> route) => false);
  }

  void showLoginView() {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("برجاء تسجيل الدخول",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color.fromRGBO(67, 160, 71, 1))),
                SizedBox(
                  height: 10,
                ),
                Text("تحتاج إلى تسجيل الدخول لعرض الميزات الكاملة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xff646464))),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 30, top: 30),
                      child: Container(
                        width: 140,
                        height: 50,
                        child: Center(
                          child: Text(
                            'تسجيل الدخول',
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
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Login()),
                          (Route<dynamic> route) => false);
                      // _navigateToNextAction();
                    })
              ],
            ),

            //alignment: Alignment.centerRight,
//              actions: <Widget>[
//                // usually buttons at the bottom of the dialog
//                new FlatButton(
//                  child: new Text(
//                    "الإعدادات",
//                    style: TextStyle(color: Color(0xff43a047)),
//                  ),
//                  onPressed: () {
//
//                  },
//                ),
//                new FlatButton(
//                  child: new Text(
//                    "إلغاء",
//                    style: TextStyle(color: Color(0xff43a047)),
//                  ),
//                  onPressed: () {
//                    Navigator.pop(context);
//                  },
//                ),
//              ],
          ),
          height: 50,
        );
      },
    );
  }
}
