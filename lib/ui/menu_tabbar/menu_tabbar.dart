import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/ui/matches/matches_list.dart';
import 'package:sporting_club/ui/more/more.dart';
import 'package:sporting_club/ui/news/news_list.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/offers_services/offers_services_list.dart';
import 'package:sporting_club/utilities/local_settings.dart';

class MenuTabBar extends StatefulWidget {
  int _currentIndex = 0;
  int news_id = 0;

  MenuTabBar(this._currentIndex,this.news_id);

  @override
  State<StatefulWidget> createState() {
    return MenuTabBarState(_currentIndex,news_id);
  }
}

class MenuTabBarState extends State<MenuTabBar> {
  int _currentIndex = 0;
  int news_id = 0;
  MenuTabBarState(this._currentIndex,this.news_id);

  final List<Widget> _children = [
    OffersServicesList(false),
    NewsList(LocalSettings.token == null?false:true,LocalSettings.newsId==null?0:1),
    MatchesList(LocalSettings.token == null?false:true),
    More(null, true, Colors.white),
  ];


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    print("heighttttttttt: " + height.toString());
    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: _children[_currentIndex],
              bottomNavigationBar: BottomAppBar(
                child: Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
//                      LocalSettings.token == null
//                          ?
                         // SizedBox(width: 50,),
                      _buildTabItem(
                          'الخدمات',
                          _currentIndex == 0
                              ? 'assets/service_ac.png'
                                  : 'assets/service_nr.png',
                          0,
                          _currentIndex == 0
                              ? Color(0xffe21b1b)
                              : Color(0xff43a047)),
                      _buildTabItem(
                          'الأخبار',
                          _currentIndex == 1
                              ? 'assets/news_tab.png'
                              : 'assets/news_tab_act.png',
                          1,
                          _currentIndex == 1
                              ? Color(0xffe21b1b)
                              : Color(0xff43a047)),
                      Expanded(child: new Text('')),
                      _buildTabItem(
                          'نتائج الفرق',
                          _currentIndex == 2
                              ? 'assets/results_ic_tab_ac.png'
                              : 'assets/results_ic_tab.png',
                          2,
                          _currentIndex == 2
                              ? Color(0xffe21b1b)
                              : Color(0xff43a047)),
//                      LocalSettings.token == null
//                          ? SizedBox():
                      _buildTabItem(
                          'المزيد',
                          _currentIndex == 3
                              ? 'assets/more_tab_act.png'
                              : 'assets/more_tab.png',
                          3,
                          _currentIndex == 3
                              ? Color(0xffe21b1b)
                              : Color(0xff43a047)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              width: width,
              padding: EdgeInsets.only(
                  top: height >= 812.0 && Platform.isIOS
                      ? height - 163
                      : height - 95),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 78,
//                  height: 100,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
                (Route<dynamic> route) => false),
          ),
//          Container(
//            width: width,
//            padding: EdgeInsets.only(top: height - 112),
//            child: Center(
//              child:Image.asset(
//                'assets/logo-1.png',
//                width: 80,
////                  height: 100,
//                fit: BoxFit.fitWidth,
//              ),
//            ),
//          ),
//          Container(
//            width: width,
//            padding: EdgeInsets.only(top: height - 33),
//            child: Center(
//              child: Text(
//                'الرئيسية',
//                style: TextStyle(color: Color(0xff43a047)),
//              ),
//            ),
//          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      LocalSettings.token == null?
          index == 0||index == 2?showLoginView():

      _currentIndex = index: _currentIndex = index;
    });
  }

  Widget _buildTabItem(
      String title, String imageName, int selectedIndex, Color color) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Image.asset(
                imageName,
                height: 30,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: color),
              )
            ],
          ),
          height: 75,
        ),
        onTap: () {
          setState(() {
            LocalSettings.token == null?
            selectedIndex == 0||selectedIndex == 2?showLoginView():

            _currentIndex = selectedIndex:
            _currentIndex = selectedIndex;
           // _currentIndex = selectedIndex;
          });
        },
      ),
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
                Text(
                    "برجاء تسجيل الدخول",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Color.fromRGBO(67, 160, 71, 1))

                ),
                SizedBox(height: 10,),
                Text(
                    "تحتاج إلى تسجيل الدخول لعرض الميزات الكاملة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xff646464))

                ),


                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 30,top: 30),
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
                          MaterialPageRoute(builder: (BuildContext context) => Login()),
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

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }



}
