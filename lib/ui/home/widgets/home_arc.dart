import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/my_shuttle_bookings.dart';

import 'package:sporting_club/ui/complaints/complaints_list.dart';
import 'package:sporting_club/ui/events/events_list.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/ui/menu_tabbar/menu_tabbar.dart';

import 'package:sporting_club/ui/offers_services/offers__list.dart';

import 'package:sporting_club/ui/restaurants/restaurants.dart';
import 'package:sporting_club/ui/sos/screens/emergency_categories.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/animation.dart';

class FlowMenu extends StatefulWidget {
 final  double curveHeight;

  const FlowMenu({Key? key, required this.curveHeight}) : super(key: key);
  @override
  _FlowMenuState createState() => _FlowMenuState();
}

class _FlowMenuState extends State<FlowMenu>
    with SingleTickerProviderStateMixin {
  AnimationController? menuAnimation;

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    menuAnimation?.addListener(() {
      // setState(() {});
    });
    menuAnimation?.forward();
    Future.delayed(Duration.zero, () {
      // buildData(context);
    });
    print(LocalSettings.user?.isDoctor??false);
    print(LocalSettings.user?.isDoctor??false);
  }

  @override
  void dispose() {
    menuAnimation?.dispose();
    super.dispose();
  }



  Widget flowMenuItem(MenuData menuData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 20,),
        menuData.child,
        // SizedBox(width:menuData.angle==-85?3: 10,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    buildData(context);
    print("flowMenuItem ${menuItems.length}");
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Flow(
            delegate: FlowMenuDelegate(
                menuAnimation: menuAnimation!, menuItems: menuItems ,curveHeight: widget.curveHeight ),
            children: menuItems
                .map<Widget>((MenuData menuData) => flowMenuItem(menuData))
                .toList(),
          ),
        ),
      ],
    );
  }


  List<MenuData> menuItems = [];
  int firstAngel=-88;

  buildData(context) {
    double  angleIcrement=19;
    menuItems = <MenuData>[
      MenuData(
        text: 'الرحلات',
        angle:firstAngel,
        child: Row(
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/trips_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : ( LocalSettings.token != null&&(LocalSettings.user?.isMember??false))
                      ?  Navigator.of(context).push(
    MaterialPageRoute(
    settings: RouteSettings(name: 'TripsList'),
    builder: (context) => TripsList(false, false, allTrips: true),
    ),
    ):showLoginView()
                      ,
            ),
            Padding(
              padding: EdgeInsets.only(bottom:50 ),
              child: Text(
                'الرحلات',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),

          ],
        ),
      ),
      MenuData(
        text: 'الفعاليات',
        angle: firstAngel+(angleIcrement*1),
        child: Row(
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/events_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : ( LocalSettings.token != null&&(LocalSettings.user?.isMember??false))
                      ?   Navigator.push(
    context,
    MaterialPageRoute(
    builder: (BuildContext context) => EventsList(true))):showLoginView()
                     ,
            ),
            SizedBox(width: 5,),
            Padding(
              padding: EdgeInsets.only(bottom:10 ),
              child: Text(
                'الفعاليات',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'النتائج',
        angle: firstAngel+(angleIcrement*2),
        child: Row(
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/results_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => MenuTabBar(2, 0))),
            ),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'النتائج',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'الأخبـار',
        angle: firstAngel+(angleIcrement*3),
        child: Row(
          children: <Widget>[
            GestureDetector(
                child: _buildCategoryIcons('assets/news_ic_2.png'),
                onTap: () {
                  if (LocalSettings.adsNetworkError??false) {
                    Fluttertoast.showToast(msg:
                        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                        toastLength: Toast.LENGTH_LONG);
                  } else {
                    LocalSettings.newsId = null;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => MenuTabBar(1, 0)));
                  }
                }),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'الأخبـار',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'المطاعم',
        angle: firstAngel+(angleIcrement*4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/restaurants_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => RestaurantsList())),
            ),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'المطاعم',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'الخدمات',
        angle: firstAngel+(angleIcrement*5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/services_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : ( LocalSettings.token != null&&(LocalSettings.user?.isMember??false))
                      ?   Navigator.push(
    context,
    MaterialPageRoute(
    builder: (BuildContext context) => MenuTabBar(0, 0))):showLoginView()
                     ,
            ),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'الخدمات',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'العروض',
        angle: firstAngel+(angleIcrement*6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              child: _buildCategoryIcons('assets/offers_ic_2.png'),
              onTap: () =>( LocalSettings.adsNetworkError??false)
                  ? Fluttertoast.showToast(msg:
                      "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                      toastLength: Toast.LENGTH_LONG)
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => OffersList(true))),
            ),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'العروض',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      MenuData(
        text: 'الشكاوى والاراء',
        angle: firstAngel+(angleIcrement*7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: _buildCategoryIcons(
                  'assets/complaiments_ic.png',
                ),
                onTap: () {
                  ( LocalSettings.token != null&&(LocalSettings.user?.isMember??false))
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ComplaintsList()))
                      : showLoginView();
                }),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'الشكاوى والاراء',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),

          ],
        ),
      ),
      MenuData(
        text: 'شاتل باص',
        angle: firstAngel+(angleIcrement*8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: _buildCategoryIcons(
                  'assets/bus_ic.png',
                ),
                onTap: () {
                  ( LocalSettings.token != null&&(LocalSettings.user?.isMember??false))
                      ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => MyShuttleBookingsScreen()))
                      : showLoginView();
                }),
            SizedBox(width: 8,),
            Padding(
              padding: EdgeInsets.only(bottom:5 ),
              child: Text(
                'شاتل باص',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),

          ],
        ),
      ),
      // MenuData(
      //   text: 'طوارئ',
      //   angle: firstAngel+(angleIcrement*9),
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.end,
      //     children: <Widget>[
      //       GestureDetector(
      //           child: _buildCategoryIcons(
      //             'assets/emergency_home_ic.png',
      //           ),
      //           onTap: () {
      //            ( LocalSettings.token != null)
      //                 ? Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (BuildContext context) => EmergencyCategoriesScreen()))
      //                 : showLoginView();
      //           }),
      //       SizedBox(width: 8,),
      //       Padding(
      //         padding: EdgeInsets.only(top:15 , right: 15),
      //         child: Text(
      //           'طوارئ',
      //           style: TextStyle(
      //               fontWeight: FontWeight.w700,
      //               fontSize: 14,
      //               color: Colors.white),
      //         ),
      //       ),
      //
      //     ],
      //   ),
      // ),
    ];
  }

  Widget _buildCategoryIcons(String iconName) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double iconsHeight = height - 250;
    return Image.asset(
      iconName,
      fit: BoxFit.fitHeight,
//      height: animation.value,
//      width: animation.value,
      height: 50,
      width: 50,
    );
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
          ),
          height: 50,
        );
      },
    );
  }
}

class FlowMenuDelegate extends FlowDelegate {
  FlowMenuDelegate({required this.menuAnimation, required this.menuItems, required this.curveHeight})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;
  final List<MenuData> menuItems;
  final  double curveHeight;

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dx = 0.0, dy = 0.0;
    for (int i = 0; i < context.childCount; ++i) {
      // dx = context.getChildSize(i).width * i;
      dx = curveHeight<600?180.0 * cos(menuItems[i].angle * (pi / 180)):220.0 * cos(menuItems[i].angle * (pi / 180));
    dy = curveHeight<600?180.0 * sin(menuItems[i].angle * (pi / 180)):230.0 * sin(menuItems[i].angle * (pi / 180));
      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          dx * 1, //menuAnimation.value,
          dy *1, // menuAnimation.value,
          0,
        ),
      );
    }
  }
}

class MenuData {
  var text;
  var angle;
  Widget child;

  MenuData({ required this.text, required this.angle,required this.child});
}
