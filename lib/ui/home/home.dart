import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/images_list_data.dart';
import 'package:sporting_club/delegates/close_panel_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/ImagesResponseListener.dart';
import 'package:sporting_club/network/repositories/info_network.dart';
import 'package:sporting_club/ui/booking/seats_number.dart';
import 'package:sporting_club/ui/events/events_list.dart';
import 'package:sporting_club/ui/home/widgets/home_arc.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/ui/menu_tabbar/menu_tabbar.dart';
import 'package:sporting_club/ui/more/more.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/offers_services/offers__list.dart';
import 'package:sporting_club/ui/offers_services/offers_services_list.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';
import 'package:sporting_club/ui/restaurants/restaurants.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/animation.dart';

import '../sos/screens/emergency_categories.dart';
import 'full_adsView.dart';
import 'package:sporting_club/ui/home/widgets/curve.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home>
    with TickerProviderStateMixin
    implements ClosePanelDeleagte, ImagesResponseListener {
  PanelController _controller = new PanelController();
  bool _isVisible = false;
  LocalSettings _localSettings = LocalSettings();

  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;

  bool _visibleFirstImg = true;
  bool _visibleSecondImg = false;
  bool closeAds = false;
  int imageIndex = 0;
  Animation<double>? animation;
  AnimationController? controller;

  StreamSubscription? subscription;
  final List<String> imagesURL = [];
  Color moreBackground = Colors.transparent;

  @override
  void initState() {
    super.initState();
    InfoNetwork _infoNetwork = InfoNetwork();

    _infoNetwork.getImageList(this);
    // print("player_id77777777${_localSettings.getPlayerId()}");
    // print("player_id77777777${LocalSettings}");

    LocalSettings.newsId = null;
    //_initBranchIO();
    getAds();

    if (LocalSettings.adsNetworkError ?? false) {
      subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        // Got a new connectivity status!
        if (result != ConnectivityResult.none) {
          print('get network');
          _infoNetwork.getAdsList(null, null, this);
        }
      });
    }
    Timer.periodic(new Duration(seconds: 5), (timer) {
      // _changeImage();
    });

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    animation = Tween<double>(begin: 63, end: 70).animate(controller!)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller?.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller?.forward();
        }
      });

    controller?.forward();
    _localSettings.getNotificationsCount().then((count) {
      // if (count < 0) {
      //   count = 0;
      // }
      LocalSettings.notificationsCount = count;
    });
    print("localcount${LocalSettings.notificationsCount}");
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent notification) {
      print("setNotificationReceivedHandler in home ");
      LocalSettings.notificationsCount = 1;

      setState(() {});
    });
    LocalSettings.open_fromterminated = true;

    print('tooookeeeeeeeeeen :::::::::::::::  ${LocalSettings.token}');
    
    print('tooookeeeeeeeeeen function :::::::::::::::  $getToken');
    getToken();
  }

  getToken() async{
    LocalSettings local = LocalSettings();
    var token = await local.getToken();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (subscription != null) {
      subscription?.cancel();
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    _localSettings.getAdvertisements();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (_controller.isPanelOpen) {
          _controller.close();
        } else {
          return true;
        }
        return false;
      },
      child: Scaffold(
        body: new Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(children: [
            SlidingUpPanel(
              controller: _controller,
              color: Colors.white.withOpacity(0),
              boxShadow: [],
              panel: More(this, false, moreBackground),
              onPanelSlide: (value) {
                setState(() {
                  moreBackground = Colors.white;
                });
              },
              onPanelClosed: () {
                setState(() {
                  moreBackground = Colors.transparent;
                });
              },
              onPanelOpened: () {
                moreBackground = Colors.white;
              },
              maxHeight: isSmallDevice(height) ? height - 63 : height - 100,
              minHeight: 60,
              collapsed: Arc(
                arcType: ArcType.CONVEX,
                edge: Edge.TOP,
                height: 40.0,
                // clipShadows: [ClipShadow(color: Colors.black)],
                child: GestureDetector(
                  onTap: () {
                    _controller.open();
                  },
                  child: new Container(
                    height: 40,
                    color: Colors.white,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.fiber_manual_record,
                                color: Color(0xffFF5C46), size: 15),
                            Icon(Icons.fiber_manual_record,
                                color: Color(0xffFF5C46), size: 15),
                            Icon(Icons.fiber_manual_record,
                                color: Color(0xffFF5C46), size: 15),
                          ],
                        ),
                        Container(
                          child: Text(
                            'المزيد',
                            style: TextStyle(
                                color: Color(0xffFF5C46),
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Image.asset(
                        //   'assets/more.png',
                        //   height: 60,
                        //   width: width,
                        //   fit: BoxFit.contain,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  Container(
                    color: Color(0xfff5f5f5),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/green_backgound.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      //                  child: _buildContent(),
                      child: _buildArcContent(),
                    ),
                  ),
                  //              _buildMoreView()
                ],
              ),
            ),
            ads != null && !closeAds && LocalSettings.open_ads
                ? Center(child: _buildAdsView())
                : SizedBox(),
          ]),
        ),
      ),
    );
  }

  Widget getSliderUrl(String? file) {
    if (file != null) {
      if (!file.isEmpty) {
        return CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: file,
          placeholder: (context, url) => Image.asset(
            'assets/img01.png',
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/img01.png',
            fit: BoxFit.fill,
          ),
        );
      } else {
        return Image.asset(
          'assets/img01.png',
          fit: BoxFit.fill,
        );
      }
    } else {
      return Image.asset(
        'assets/img01.png',
        fit: BoxFit.fill,
      );
    }
  }

  _buildImagesSlider() {
    double height = MediaQuery.of(context).size.height;
//    final List<String> imagesURL = [
//      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
//      'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
//      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
//      'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
//      'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
//      'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
//    ];
    if (imagesURL.length > 0) {
      if (imagesURL.length > 1) {
        return CarouselSlider(
          options: CarouselOptions(
            height: isSmallDevice(height) ? 350 : 460,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            autoPlayAnimationDuration: Duration(milliseconds: 3),
            pauseAutoPlayOnTouch: false,
            autoPlay: imagesURL.length > 1 ? true : false,
            enlargeCenterPage: false,
            onPageChanged: (index, _) {
//          setState(() {
//          });
//            bloc.changeImageSliderIndex(index);
            },
          ),
          items: imagesURL.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            bottomRight: const Radius.circular(350.0),
                            topRight: const Radius.circular(350.0))),
                    child: ClipRRect(
                      borderRadius: new BorderRadius.only(
                          bottomRight: const Radius.circular(350.0),
                          topRight: const Radius.circular(350.0)),
                      child: getSliderUrl(url),
                    ));
              },
            );
          }).toList(),
        );
      } else {
        return Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                  bottomRight: const Radius.circular(350.0),
                  topRight: const Radius.circular(350.0)),
            ),
            child: ClipRRect(
              borderRadius: new BorderRadius.only(
                  bottomRight: const Radius.circular(350.0),
                  topRight: const Radius.circular(350.0)),
              child: getSliderUrl(imagesURL[0]),
            ));
      }
    } else {
      return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.only(
                bottomRight: const Radius.circular(350.0),
                topRight: const Radius.circular(350.0)),
          ),
          child: ClipRRect(
            borderRadius: new BorderRadius.only(
                bottomRight: const Radius.circular(350.0),
                topRight: const Radius.circular(350.0)),
            child: getSliderUrl(null),
          ));
    }
  }

  Widget _buildArcContent() {
    print("_buildArcContent");
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double containerHeight = height - 160;
    double paddingTop = (containerHeight - 450) / 2;
//    print("containerHeight: "+containerHeight.toString());
    print("containerHeight $containerHeight");
    if (containerHeight < 530) {
      //decrease height of the view like iphone 5
      height = 599;
    }
    print("height $height");

    bool isLoggedin = false;
    if (LocalSettings.token != null) {
      isLoggedin = true;
    }

    return Container(
      width: width,
      height: height - 10,
      child: Center(
        child: Container(
            width: width,
            height: height - 10,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(top: 20, left: 20),
                      child: GestureDetector(
                        onTap: () {
                          LocalSettings.token == null
                              ? showLoginView()
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          NotificationsList()));
                        },
                        child: Image.asset(
                          LocalSettings.notificationsCount != null
                              ? (LocalSettings.notificationsCount ?? 0) > 0
                                  ? 'assets/ic_not_ac.png'
                                  : 'assets/ic_not_nr.png'
                              : 'assets/ic_not_nr.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: paddingTop < 0 ? 0 : 20,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        width: height < 650 ? 230 : 270,
                        height: isSmallDevice(height) ? 410 : 510,
                        // width: 270,
                        // height:510,
                        child: Image.asset(
                          'assets/orbit.png',
                          fit: BoxFit.fill,
                        ),
                      ),

                      Visibility(
                        child: AnimatedOpacity(
                          // If the widget is visible, animate to 0.0 (invisible).
                          // If the widget is hidden, animate to 1.0 (fully visible).
                          opacity: 1.0,
                          duration: Duration(milliseconds: 1000),
                          // The green box must be a child of the AnimatedOpacity widget.
                          child: Container(
                            padding: EdgeInsets.only(top: 80),
                            width: isSmallDevice(height) ? 150 : 190,
                            height: isSmallDevice(height) ? 350 : 460,
                            child: Image.asset(
                              'assets/img02.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        visible: imagesURL.length == 0,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 60),
                        width: isSmallDevice(height) ? 150 : 190,
                        height: isSmallDevice(height) ? 350 : 460,
                        child: _buildImagesSlider(),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 80),
                        width: isSmallDevice(height) ? 150 : 190,
                        height: isSmallDevice(height) ? 350 : 460,
                        child: Image.asset(
                          'assets/home_logo.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      // RotatedBox(
                      //   quarterTurns: 1,
                      //   child: Container(
                      //     height: MediaQuery.of(context).size.height,
                      //     width: MediaQuery.of(context).size.width,
                      //     child: ClipPath(
                      //       clipper: new CustomHalfCircleClipper(),
                      //       child: new Container(
                      //         height: MediaQuery.of(context).size.height,
                      //         width: MediaQuery.of(context).size.width,
                      //         decoration: new BoxDecoration(
                      //             border: Border.all(color: Colors.white , width: 2),
                      //             borderRadius: BorderRadius.circular(
                      //                 MediaQuery.of(context).size.width )),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        height: isSmallDevice(height) ? 450 : 550,
                      ),
                      Container(
                          width: isSmallDevice(height) ? 400 : 500,
                          height: isSmallDevice(height) ? 420 : 520,
                          // height: 520, width: 500,
                          child: FlowMenu(
                            curveHeight: height,
                          )),
                      Positioned(
                        bottom: 0,
                        right: (MediaQuery.of(context).size.width / 2) - 15,
                        // left: 10,
                        child: GestureDetector(
                          onTap: () {
                            (LocalSettings.token != null)
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            EmergencyCategoriesScreen()))
                                : showLoginView();
                          },
                          child: Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100)),
                            child: Image.asset(
                              "assets/sos_ic.png",
                              fit: BoxFit.contain,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  bool isSmallDevice(double height) => height <= 670;

  Widget buildLoginCircle(double height) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: isSmallDevice(height) ? 338 : 395,
            left: isSmallDevice(height) ? 120 : 150,
          ),
          child: GestureDetector(
            child: _buildCategoryIcons('assets/news_ic_2.png'),
            onTap: () => (LocalSettings.adsNetworkError ?? false)
                ? Fluttertoast.showToast(
                    msg:
                        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
                    toastLength: Toast.LENGTH_LONG)
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Login()),
                  ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: isSmallDevice(height) ? 338 : 400, left: 5),
          child: Text(
            'تسجيل الدخول',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeIcons(String iconName) {
    double width = MediaQuery.of(context).size.width;
    return Image.asset(
      iconName,
      fit: BoxFit.fitWidth,
      width: width / 3 - 35,
    );
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

  Widget _buildTitle() {
    return Column(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Text(
              'أهلا بكم',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: Colors.white),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: Text(
              'في نادي سبورتنج',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMoreView() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: 0, top: height - 80),
      child: Stack(
        children: <Widget>[
          SlidingUpPanel(
            panel: Image.asset(
              'assets/simicircle.png',
              fit: BoxFit.fill,
              width: width,
              height: 80,
            ),
            collapsed: Container(
              color: Colors.blueGrey,
              child: Center(
                child: Text(
                  "This is the collapsed Widget",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            body: Center(
              child: Text("This is the Widget behind the sliding panel"),
            ),
          ),

//         Center(child: Padding(padding: EdgeInsets.only(top: 15), child: Text('المزيد'),),)
        ],
      ),
    );
  }

  Widget _buildAdsView() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return (ads?[0].images?.length ?? 0) > 0
        ? FullAdsView(
            ads?[0].images?[viewedAdvIndex].large ?? "",
            _adsAction,
            () => setState(() {
              closeAds = true;
              LocalSettings.open_ads = false;
            }),
          )
        : SizedBox();
  }

  void _adsAction() async {
    //log ads action event
    if (ads?.isNotEmpty ?? false) {
      if (ApiUrls.RELEASE_MODE) {
        if (ads?[0].images?[viewedAdvIndex].title != null) {
          if (ads?[0].images?[viewedAdvIndex].title?.isNotEmpty ?? false) {
            FirebaseAnalytics analytics = FirebaseAnalytics.instance;
            analytics.logEvent(
              name: 'advertisements',
              parameters: <String, String>{
                'ad_name': ads?[0].images?[viewedAdvIndex].title ?? "",
              },
            );
          }
        }
      }
      if (ads?[0].images?[viewedAdvIndex].link != null) {
        if (await UrlLauncher.canLaunch(
            ads?[0].images?[viewedAdvIndex].link ?? "")) {
          await UrlLauncher.launch(ads?[0].images?[viewedAdvIndex].link ?? "");
        } else {
          print("can't launch");
        }
      }
    }
  }

  void getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads =
          LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty ?? false) {
        for (AdvertisementData adv in ads ?? []) {
          if (adv.name == "home_page") {
            setState(() {
              if (adv.data?.isNotEmpty ?? false) {
                if (adv.data?[0].date_from != null &&
                    adv.data?[0].date_to != null) {
                  _checkAdsTime(adv) ? this.ads = adv.data : this.ads = null;
                  _setAdsTimer();
                } else {
                  this.ads = adv.data;
                  _setAdsTimer();
                }
              }
            });
            break;
          }
        }
      }
    }
  }

  void _setAdsTimer() {
    int duration = 3;
    if (ads != null) {
      if (ads?[0].image_duration != null && ads?[0].image_duration != "") {
        duration = int.parse(ads?[0].image_duration ?? "0");
      }
      _timer = Timer.periodic(new Duration(seconds: duration), (timer) {
        if ((ads?[0].images?.length ?? 0) - 1 > viewedAdvIndex) {
          setState(() {
            viewedAdvIndex += 1;
          });
        } else {
          setState(() {
            viewedAdvIndex = 0;
          });
        }
      });
    }
  }

  bool _checkAdsTime(AdvertisementData adv) {
    final startTime = DateTime.parse(adv.data?[0].date_from ?? "2000-01-01");

    final endTime = DateTime.parse(adv.data?[0].date_to ?? "2000-01-01");

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      // do something
      print('valid date');
      return true;
    } else {
      return false;
    }
  }

  void _changeImage() {
    if (imageIndex == 0) {
      setState(() {
        imageIndex = 1;
        _visibleFirstImg = false;
        _visibleSecondImg = true;
      });
    } else {
      setState(() {
        imageIndex = 0;
        _visibleFirstImg = true;
        _visibleSecondImg = false;
      });
    }

//    if(_height == 50){
//      setState(() {
//        _height = 80;
//        _width = 80;
//      });
//    }else{
//      setState(() {
//        _height = 50;
//        _width = 50;
//      });
//    }
  }

  @override
  void closePanel() {
    _controller.close();
  }

  @override
  void hideLoading() {
    // TODO: implement hideLoading
  }

  @override
  void showAuthError() {
    // TODO: implement showAuthError
  }

  @override
  void showGeneralError() {
    // TODO: implement showGeneralError
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
    print(" showLoading");
  }

  @override
  void showLoginError(String? error) {
    // TODO: implement showLoginError
    print(" showLoginError");
  }

  @override
  void showNetworkError() {
    print(" showNetworkError");

    // TODO: implement showNetworkError
  }

  @override
  void showServerError(String? msg) {
    // TODO: implement showServerError
    print(" showServerError");
  }

  @override
  void showSuccess(ImagesListData? data) {
    // TODO: implement showSuccess
    print(" images");

    setState(() {
      imagesURL.clear();
      imagesURL.addAll(data?.images ?? []);
    });
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

const double _kCurveHeight = 35;
