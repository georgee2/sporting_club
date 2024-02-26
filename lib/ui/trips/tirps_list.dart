import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/data/model/trips/trips_interests_data.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/delegates/interests_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/TripsResponseListener.dart';
import 'package:sporting_club/network/repositories/trips_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:intl/intl.dart' as intl;

class TripsList extends StatefulWidget {
  bool _isFromPushNotification = false;
  bool isShowMyTripsOnly = false;
  bool allTrips;


  TripsList(this._isFromPushNotification,this.isShowMyTripsOnly, {this.allTrips=false});

  @override
  State<StatefulWidget> createState() {
    return TripsListState(this._isFromPushNotification,this.isShowMyTripsOnly
    );
  }
}

class TripsListState extends State<TripsList>
    implements
        NoNewrokDelagate,
        TripsResponseListener,
        InterestsDeleagte,
        ReloadTripsDelagate,
        NewsDeleagte{
  bool _isFromPushNotification = false;
  bool _isloading = false;
  bool _isMyTrips = true;
  String _selectedTripsFilter = "inner";
  String _selectedMyTripsFilter = "";

  bool _isOuterInterestTrips = false;
  bool _isInnerInterestTrips = false;

  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;
  TripsNetwork _tripsNetwork = TripsNetwork();

  List<Trip> _trips = [];

  int _page = 1;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isNoInterest = false;
  DateTime _selectedDate= DateTime.now();
  bool isShowMyTripsOnly = false;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;

  TripsListState(this._isFromPushNotification,this.isShowMyTripsOnly);

  @override
  void initState() {
    super.initState();
    LocalSettings.link = "";

    List<String> list = LocalSettings.interests??[];
    print("isShowMyTripsOnly$isShowMyTripsOnly");
//    if (!list.contains('trips')) {
//      _isMyTrips = false;
//    }
    _isMyTrips =isShowMyTripsOnly;

    _selectedDate = DateTime.now();

    if (_isMyTrips) {
      _tripsNetwork.getTripsInterests(this);
    } else if(widget.allTrips) {
      _tripsNetwork.getTrips(_selectedTripsFilter == "inner" ? 0 : 1, _page, true,null, this);
    }else {
    String filterDate =
      new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _tripsNetwork.getTrips(
          _selectedTripsFilter == "inner" ? 0 : 1, _page, true,filterDate, this);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
    });
    if (ApiUrls.RELEASE_MODE) {
      _sendAnalyticsEvent();
    }
    _getAds();
    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in trips ");
      LocalSettings.notificationsCount =  1;
      initState();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        _isFromPushNotification
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
                (Route<dynamic> route) => false)
            : Navigator.of(context).pop(null);

        return true;
      },
      child: ModalProgressHUD(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: Color(0xff43a047),
            child: SafeArea(
              bottom: false,
              child: Material(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPersistentHeader(
                      delegate: TripsListSliverAppBar(
                          expandedHeight: _isMyTrips?200:250,
                          tripsList: this,
                          reloadTripsDelagate: this,isShowMyTripsOnly:isShowMyTripsOnly,newsDeleagte: this),
                      pinned: true,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (_isNoNetwork) {
                            return _buildImageNetworkError();
                          } else if (_isNoData) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _buildNoData(),
                                Text(
                                  "حجز الرحلات اونلاين قريبا",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 18, color: Colors.grey),
                                )
                              ],
                            );
                          } else if (_isMyTrips && _isNoInterest) {
                            print('build _isNoInterest');
                            return _buildNoInterests();
                          } else {
                            return _getViewedItem(index);
                          }
                        },
                        childCount: _isNoData ||
                                _isNoNetwork ||
                                (_isMyTrips && _isNoInterest)
                            ? 1
                            : _trips.isEmpty
                                ? 0
                                : _isNoMoreData
                                    ? _trips.length + 1 //data + ads
                                    : _trips.length + 2, //data + ad
                        //                          : _isNoMoreData ? _events.length : _events.length + 1,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        inAsyncCall: _isloading,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Color.fromRGBO(0, 112, 26, 1),
          valueColor:
              AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
        ),
      ),
    );
  }

  Widget _buildTripsFilter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _isMyTrips
            ? _isInnerInterestTrips
                ? _buildTripsFilterItem("inner")
                : SizedBox()
            : _buildTripsFilterItem("inner"),
        _isMyTrips
            ? _isOuterInterestTrips
                ? _buildTripsFilterItem("outer")
                : SizedBox()
            : _buildTripsFilterItem("outer"),

      ],
    );
  }

  Widget _buildTripsFilterItem(String type) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
          child: Text(
            type == "inner" ? "رحلات داخلية" : "رحلات خارجية",
            style: TextStyle(
              color: _isMyTrips && _selectedMyTripsFilter == type
                  ? Colors.white
                  : !_isMyTrips && _selectedTripsFilter == type
                      ? Colors.white
                      : Color(0xffb1e6b1),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _isMyTrips && _selectedMyTripsFilter == type
                  ? Color(0xff43a047)
                  : !_isMyTrips && _selectedTripsFilter == type
                      ? Color(0xff43a047)
                      : Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _isMyTrips && _selectedMyTripsFilter == type
                ? Color(0xff43a047)
                : !_isMyTrips && _selectedTripsFilter == type
                    ? Color(0xff43a047)
                    : Colors.transparent,
          ),
        ),
        onTap: () {
          setState(() {
            if (_isMyTrips) {
              if (_selectedMyTripsFilter != type) {
                _selectedMyTripsFilter = type;
                _resetTripsData();
              }
            } else {
              _selectedTripsFilter = type;
              _resetTripsData();
            }
          });
        },
      ),

    );
  }

  Widget _buildTripsItem(int index) {
    double width = MediaQuery.of(context).size.width;

    String startDay = "";
    String startMonth = "";
    if (_trips[index].start_date != null) {
      intl.DateFormat dateFormat = intl.DateFormat("dd-MM-yyyy");
      DateTime dateTime = dateFormat.parse(_trips[index].start_date??"2000-01-01");
      startDay = intl.DateFormat.d('en_US').format(dateTime);
//      print(startDay);
      startMonth = intl.DateFormat.MMMM('ar_EG').format(dateTime);
//      print(startMonth);
    }
    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 30 : 5, bottom: 10),
          child: Container(
            height: 125,
//          width: 300,
//          padding: EdgeInsets.only(bottom: 5, right: 10, left: 10, top: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 8.0, // has the effect of softening the shadow
                  spreadRadius: 5.0, // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    0.0, // vertical, move down 10
                  ),
                ),
              ],
              color: Colors.white,
            ),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: _trips[index].image != null
                          ? _trips[index].image?.medium != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder_2.png',
                                  image: _trips[index].image?.medium??"",
                                  height: 125,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/placeholder_2.png',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.fill,
                                )
                          : Image.asset(
                              'assets/placeholder_2.png',
                              height: 125,
                              width: 120,
                              fit: BoxFit.fill,
                            ),
                    ),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Image.asset(
                          'assets/calendar_label_2.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            startMonth,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Text(
                            startDay,
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: width - 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 5, top: 12),
                        child: Align(
                          child: Text(
                            _trips[index].name??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, top: 0, bottom: 5),
                                  child: Text(
                                    "اﻷماكن المتاحة",
                                    style: TextStyle(
                                        color: Color(0xff76d275),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              ),
                              Align(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, top: 0, bottom: 0),
                                  child: Text(
                                    _trips[index].available_seats != null
                                        ? _trips[index]
                                            .available_seats
                                            .toString()
                                        : "",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              )
                            ],
                          ),
                          _trips[index].waiting_list_count != null
                              ? _trips[index].waiting_list_count != 0
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Align(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10,
                                                left: 10,
                                                top: 0,
                                                bottom: 5),
                                            child: Text(
                                              "قائمة الانتظار",
                                              style: TextStyle(
                                                  color: Color(0xffff5c46),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                        ),
                                        Align(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10,
                                                left: 10,
                                                top: 0,
                                                bottom: 0),
                                            child: Text(
                                              _trips[index]
                                                  .waiting_list_count
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                        )
                                      ],
                                    )
                                  : SizedBox()
                              : SizedBox(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, top: 0, bottom: 2),
                              child: Text(
                                "انتهاء الحجز",
                                style: TextStyle(
                                    color: Color(0xffb6b9c0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                          Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, top: 0, bottom: 2),
                              child: Text(
                                _trips[index].booking_end_date ??"",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
//      onTap: () => Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (BuildContext context) =>
//                  TripDetails(_trips[index].id))),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          settings: RouteSettings(name: 'TripDetails'),
          builder: (context) =>
              TripDetails(_trips[index].id??0, this, _isFromPushNotification),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(
            backgroundColor: Color.fromRGBO(0, 112, 26, 1),
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildNoData() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 50;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoData('لا توجد رحلات'),
    );
  }

  Widget _buildNoInterests() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//          Image.asset('assets/eye-close-line.png'),
            Text(
              "حجز الرحلات اونلاين قريبا",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.grey),
            ),
            // Text(
            //   'حدد رحلاتك المفضلة من هنا',
            //   style: TextStyle(
            //       fontWeight: FontWeight.w700,
            //       fontSize: 16,
            //       color: Colors.grey),
            // ),
            SizedBox(
              height: 20,
            ),

            // GestureDetector(
            //   child: Container(
            //     height: 50,
            //     padding:
            //         EdgeInsets.only(bottom: 5, right: 20, left: 20, top: 10),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(.2),
            //           blurRadius: 8.0, // has the effect of softening the shadow
            //           spreadRadius:
            //               5.0, // has the effect of extending the shadow
            //           offset: Offset(
            //             0.0, // horizontal, move right 10
            //             0.0, // vertical, move down 10
            //           ),
            //         ),
            //       ],
            //       color: Color(0xffff5c46),
            //     ),
            //     child: Text(
            //       'اختار رحلاتك المفضلة',
            //       style: TextStyle(
            //           fontWeight: FontWeight.w700,
            //           fontSize: 18,
            //           color: Colors.white),
            //     ),
            //   ),
            //   onTap: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (BuildContext context) =>
            //               Interests(true, this, 2, updateInterestsNow: true,))),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoNetwork(this),
    );
  }

  Widget _buildAdsView() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 5),
      child: GestureDetector(
        child: Container(
          child: ( ads?[0].images?.length??0) > 0
              ? Image.network(
                  ads?[0].images?[viewedAdvIndex].large??"",
                  fit: BoxFit.cover,
                )
              : SizedBox(),
          //height: 75,
          // width: width - 30,
        ),
        onTap: () => _adsAction(),
      ),
    );
  }

  Widget _getViewedItem(int index) {
    if (_trips.length >= 2) {
      if (index < 2) {
        return _buildTripsItem(index); //before 2 so events item
      } else if (index == 2) {
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (!_isNoMoreData && index == _trips.length + 1) {
        //we still have pages so build loader
        return _buildProgressIndicator();
      } else {
        return _buildTripsItem(index - 1); //build events items after ads
      }
    } else {
      //less than 2 items
      if (index == _trips.length) {
        //ads
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (index == _trips.length + 1) {
        //loader
        return _buildProgressIndicator();
      } else {
        return _buildTripsItem(index);
      }
    }
  }

  void _adsAction() async {
    //log ads action event
    if (ads?.isNotEmpty??false) {
      if (ApiUrls.RELEASE_MODE) {
        if (ads?[0].images?[viewedAdvIndex].title != null) {
          if (ads?[0].images?[viewedAdvIndex].title?.isNotEmpty??false) {
            FirebaseAnalytics analytics = FirebaseAnalytics.instance;
            analytics.logEvent(
              name: 'advertisements',
              parameters: <String, String>{
                'ad_name': ads?[0].images?[viewedAdvIndex].title??"",
              },
            );
          }
        }
      }
      if (ads?[0].images?[viewedAdvIndex].link != null) {
        if (await UrlLauncher.canLaunch(ads?[0].images?[viewedAdvIndex].link??"")) {
          await UrlLauncher.launch(ads?[0].images?[viewedAdvIndex].link??"");
        } else {
          print("can't launch");
        }
      }
    }
  }

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == "list_trips") {
            setState(() {
              if (adv.data?.isNotEmpty??false) {
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
      if (ads?[0].image_duration != null) {
        duration = int.parse(ads?[0].image_duration??"0");
      }
      _timer = Timer.periodic(new Duration(seconds: duration), (timer) {
        if ((ads?[0].images?.length??0) - 1 > viewedAdvIndex) {
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
    final startTime = DateTime.parse(adv.data?[0].date_from??"2000-01-01");

    final endTime = DateTime.parse(adv.data?[0].date_to??"2000-01-01");

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      // do something
      print('valid date');
      return true;
    } else {
      return false;
    }
  }

  void _changeTripsSelection(bool isMyTrips) {
    setState(() {
      _isMyTrips = isMyTrips;
      _resetTripsData();
    });
  }

  void _resetTripsData() {
    print('_resetNewsData');
    _page = 1;
    _trips.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
//    if (_isMyTrips) {
//      _tripsNetwork.getTrips(
//          _selectedMyTripsFilter == "inner" ? 0 : 1, _page, true, this);
//    } else {
//      _tripsNetwork.getTrips(
//          _selectedTripsFilter == "inner" ? 0 : 1, _page, true, this);
//    }
//    if (_isMyTrips) {
////      if (!_isNoInterest) {
////        _tripsNetwork.getTrips(
////            _selectedMyTripsFilter == "inner" ? 0 : 1, _page, true, this);
////      }
//      _tripsNetwork.getTripsInterests(this);
//    } else {
//      _tripsNetwork.getTrips(
//          _selectedTripsFilter == "inner" ? 0 : 1, _page, true, this);
//    }

    if (_isMyTrips) {
      _tripsNetwork.getTripsInterests(this);

    }else if(widget.allTrips) {
      _tripsNetwork.getTrips(_selectedTripsFilter == "inner" ? 0 : 1, _page, true,null, this);
    }
    else {
      String filterDate =
      new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);

      _tripsNetwork.getTrips(
          _selectedTripsFilter == "inner" ? 0 : 1, _page, true,filterDate, this);
    }
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);

        if (_isMyTrips) {
          String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
          _tripsNetwork.getTrips(
              _selectedMyTripsFilter == "inner" ? 0 : 1, _page, false, filterDate,this);
        } else if(widget.allTrips) {
          _tripsNetwork.getTrips(_selectedTripsFilter == "inner" ? 0 : 1, _page, true,null, this);
        }else {
          String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
          _tripsNetwork.getTrips(_selectedTripsFilter == "inner" ? 0 : 1, _page, false, filterDate,this);
        }
      }
    }
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: 'trips_list');
  }

  @override
  void reloadAction() {
    if (_isMyTrips) {
      if (_selectedMyTripsFilter != "") {
        String filterDate =
        new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
        _tripsNetwork.getTrips(
            _selectedMyTripsFilter == "inner" ? 0 : 1, _page, true,filterDate, this);
      } else {
        _tripsNetwork.getTripsInterests(this);
      }
    } else if(widget.allTrips) {
      _tripsNetwork.getTrips(_selectedTripsFilter == "inner" ? 0 : 1, _page, true,null, this);
    }else {
      String filterDate =
      new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _tripsNetwork.getTrips(
          _selectedTripsFilter == "inner" ? 0 : 1, _page, true,filterDate, this);
    }
  }

  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
      _isPerformingRequest = false;
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
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
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
  void addInterests() {
    //once success to add interest so we need to refresh events
    //reset data
    _page = 1;
    _trips.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    _tripsNetwork.getTripsInterests(this);
  }

  @override
  void setTrips(TripsData? tripsData) {
    _page += 1;
    if (tripsData?.trips != null) {
      if (tripsData?.trips?.isEmpty??true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._trips.addAll(tripsData?.trips??[]);
        _isPerformingRequest = false;
        _isNoNetwork = false;
      });
    }
    setState(() {
      if (this._trips.isEmpty) {
        if (_isMyTrips) {
          if (!this._isNoInterest) {
            _isNoData = true;
          } else {
            _isNoData = false;
          }
        } else {
          _isNoData = true;
        }
      } else {
        _isNoData = false;
      }
    });
  }

  @override
  void setInterests(TripsInterestsData? tripsInterestsData) {
    setState(() {
      if (tripsInterestsData?.has_interests != null) {
        this._isNoInterest = !(tripsInterestsData?.has_interests??false);
      }
      if (tripsInterestsData?.interestes != null) {
        if (tripsInterestsData?.interestes?.contains("inner")??false) {
          this._isInnerInterestTrips = true;
        }
        if (tripsInterestsData?.interestes?.contains("outer")??false) {
          this._isOuterInterestTrips = true;
        }
      }
      if (_selectedMyTripsFilter.isEmpty) {
        _isInnerInterestTrips
            ? _selectedMyTripsFilter = "inner"
            : _isOuterInterestTrips
                ? _selectedMyTripsFilter = "outer"
                : _selectedMyTripsFilter = "";
      }
    });
    if (_selectedMyTripsFilter != "") {
      String filterDate =
      new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _tripsNetwork.getTrips(
          _selectedMyTripsFilter == "inner" ? 0 : 1, _page, true,filterDate, this);
    }
  }

  @override
  void reloadTripsAfterBooking(User? user) {
    print("reloadTripsAfterBooking");
    _resetTripsData();
  }

  //added
  Widget _buildSelectedDate() {
    return GestureDetector(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 15, left: 15, top: 0),
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/calender_small.png',
                  width: 15,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
//                    '${intl.DateFormat.yMMM('ar_EG').format(_selectedDate)}',
                  intl.DateFormat.MMM('ar_EG').format(
                      //isMyTrips
                    //  ? _interestsSelectedDate
                  //    :
                  _selectedDate) +
                      " " +
                      intl.DateFormat.y('en_US').format(
                         // _isMyTrips ? _interestsSelectedDate :
                          _selectedDate),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Color(0xff76d275)),
          ),
          // remove 2
        ],
      ),
      onTap: () => _showDataPicker(),
    );
  }


  void _showDataPicker() {
    showMonthPicker(
        context: context,
            firstDate: DateTime(DateTime.now().year, DateTime.now().month),
           // lastDate: DateTime(DateTime.now().year, DateTime.now().month),
        initialDate:
        //_isMyTrips ? _interestsSelectedDate :
        _selectedDate)
        .then((date) => setState(() {
      if (date != null) {
      //  if (_isMyTrips) {
        //  _interestsSelectedDate = date;
       // } else {
          _selectedDate = date;
    //    }
        _resetTripsData();
      }
    }));
  }

  @override
  void onNotificationClicked() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>     NotificationsList(),

          ));
    });
    // TODO: implement onNotificationClicked
  }

  @override
  void selectedSubCategory(Category category) {
    // TODO: implement selectedSubCategory
  }

}

class TripsListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  TripsListState tripsList;
  ReloadTripsDelagate reloadTripsDelagate;
  bool isShowMyTripsOnly = false;
  NewsDeleagte newsDeleagte;

  TripsListSliverAppBar({
     this.expandedHeight=0,
  required  this.tripsList,
  required this.reloadTripsDelagate,
  required this.isShowMyTripsOnly,
  required this.newsDeleagte
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
//    print('shrinkOffset: ' + shrinkOffset.toString());
    double width = MediaQuery.of(context).size.width;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Container(
          color: shrinkOffset < 140 ? Colors.transparent : Color(0xff43a047),
          height: 80,
        ),
        Image.asset(
          "assets/background_category.png",
          fit: shrinkOffset < 140 ? BoxFit.fill : BoxFit.cover,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 0, top: 5),
            child: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => tripsList._isFromPushNotification
                  ? Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Home()),
                      (Route<dynamic> route) => false)
                  : Navigator.of(context).pop(null),
            ),
          ),
          alignment: Alignment.topRight,
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Align(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 5),
                  child: IconButton(
                    icon: new Image.asset('assets/ic_search_white.png'),
//              onPressed: () => Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) => Search('TRIPS'))),
                    onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            Search('TRIPS',"",  reloadTripsDelagate))),
                  ),
                ),
                alignment: Alignment.topLeft,
              ),

              LocalSettings.token != null?_buildNotificationIcon(
                LocalSettings.notificationsCount != null
                    ? (LocalSettings.notificationsCount??0) > 0
                    ? 'assets/ic_not_ac.png'
                    : 'assets/ic_not_nr.png'
                    : 'assets/ic_not_nr.png',

              ):SizedBox(),
            ]
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: shrinkOffset > 90 ? 0 : 50,
//                right: shrinkOffset > 110 ? 0 : 0,
//                left: shrinkOffset > 110 ? 100 : 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      tripsList._isMyTrips
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'رحلاتي',
                          style: TextStyle(
                              color: tripsList._isMyTrips
                                  ? Colors.white
                                  : Color(0xffb1e6b1),
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          tripsList._changeTripsSelection(true);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && tripsList._isMyTrips,
                      )
                    ],
                  ),
                  visible:!isShowMyTripsOnly?false
                    :shrinkOffset > 90
                      ? tripsList._isMyTrips ? true : false
                      : true,
                ),
                SizedBox(
                  width: shrinkOffset > 90 ? 0 : 30,
                ),
                Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      !tripsList._isMyTrips
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'كل الرحلات',
                          style: TextStyle(
                              color: tripsList._isMyTrips
                                  ? Color(0xffb1e6b1)
                                  : Colors.white,
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          tripsList._changeTripsSelection(false);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && !tripsList._isMyTrips,
                      )
                    ],
                  ),
                  visible: isShowMyTripsOnly?false:shrinkOffset > 90
                      ? !tripsList._isMyTrips ? true : false
                      : true,
                ),
              ],
            ),
          ),
        ),
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 90,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight)),
              child: Align(
                child: GestureDetector(
                  child: Center(
                    child: tripsList._buildTripsFilter(),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          visible: shrinkOffset < 20 ? true : false,
        ),
      (( ! tripsList._isMyTrips)&&(!tripsList.widget.allTrips))?
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 190,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight)),
              child: Align(
                child: GestureDetector(
                  child: Center(
                    child: tripsList._buildSelectedDate(),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          visible:  shrinkOffset < 20 ? true : false,
        ) : SizedBox()
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  Widget _buildNotificationIcon(
      String imageName) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 0, top: 15),
        child: Align(
          child: GestureDetector(
            child: Container(
              child: Column(
                children: <Widget>[

                  Image.asset(
                    imageName,
                    height: 30,
                    fit: BoxFit.fitHeight,
                  ),


                ],
              ),
            ),
            onTap: () {
              LocalSettings.notificationsCount = 0;
              newsDeleagte.onNotificationClicked();


            },
          ),
          alignment: Alignment.topLeft,
        ));
  }


}
