import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/event.dart';
import 'package:sporting_club/data/model/events_data.dart';
import 'package:sporting_club/data/model/news.dart';
import 'package:sporting_club/delegates/interests_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/EventsResponseListener.dart';
import 'package:sporting_club/network/repositories/events_network.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'event_details.dart';

class EventsList extends StatefulWidget {
  bool isShowMyEventsOnly = false;
  EventsList(this.isShowMyEventsOnly);
  @override
  State<StatefulWidget> createState() {
    return EventsListState(this.isShowMyEventsOnly);
  }
}


class EventsListState extends State<EventsList>
    implements NoNewrokDelagate, EventsResponseListener, InterestsDeleagte,NewsDeleagte {
  DateTime _selectedDate=DateTime.now();
  DateTime _interestsSelectedDate=DateTime.now();
  bool isShowMyEventsOnly = false;

  bool _isloading = false;
  bool _isMyEvents = true;

  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;
  EventsNetwork _eventsNetwork = EventsNetwork();

  List<Event> _events = [];

  int _page = 1;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isNoInterest = false;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;

  EventsListState(this.isShowMyEventsOnly);

  @override
  void initState() {
    super.initState();
    List<String>? list = LocalSettings.interests;
    LocalSettings.link = "";
//    if (!list.contains('events')) {
//      _isMyEvents = false;
//    }
    _isMyEvents = isShowMyEventsOnly;
    _selectedDate = DateTime.now();
    _interestsSelectedDate = DateTime.now();

    if (_isMyEvents) {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_interestsSelectedDate);
      _eventsNetwork.getInterestsEvents(filterDate, _page, true, this);
    } else {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _eventsNetwork.getEvents(filterDate, _page, true, this);
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
      print("setNotificationReceivedHandler in events service ");
      LocalSettings.notificationsCount =  1;

      setState(() {

      });
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
    return ModalProgressHUD(
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
                    delegate: EventsListSliverAppBar(
                        expandedHeight: 200, eventsList: this,isShowMyEventsOnly:isShowMyEventsOnly,newsDeleagte: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (_isNoNetwork) {
                          return _buildImageNetworkError();
                        } else if (_isNoData) {
                          return _buildNoData();
                        } else if (_isMyEvents && _isNoInterest) {
                          print('build _isNoInterest');
                          return _buildNoInterests();
                        } else {
                          return _getViewedItem(index);
                        }
//                        } else if (_isNoMoreData) {
//                          return _buildEventItem(index);
//                        } else {
//                          return index == _events.length
//                              ? _buildProgressIndicator()
//                              : _buildEventItem(index);
//                        }
                      },
                      childCount: _isNoData ||
                              _isNoNetwork ||
                              (_isMyEvents && _isNoInterest)
                          ? 1
                          : _events.isEmpty
                              ? 0
                              : _isNoMoreData
                                  ? _events.length + 1 //data + ads
                                  : _events.length + 2, //data + ad
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
    );
  }

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
                  intl.DateFormat.MMM('ar_EG').format(_isMyEvents
                          ? _interestsSelectedDate
                          : _selectedDate) +
                      " " +
                      intl.DateFormat.y('en_US').format(
                          _isMyEvents ? _interestsSelectedDate : _selectedDate),
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

  Widget _buildEventItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 25 : 5, bottom: 10),
          child: Container(
            height: 100,
//          width: width - 20,
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
                SizedBox(
                  width: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/calender.png',
                        ),
                        Text(
                          _events[index].date ??"",
                          style: TextStyle(color: Colors.white, fontSize: 26),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text(
                            _events[index].date_month ??"",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      _events[index].date_day ??"",
                      style: TextStyle(
                          color: Color(0xff43a047),
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: width - 105,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Align(
                      child: Text(
                        _events[index].title ??"",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  EventDetails(_events[index].id??""))),
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
      child: NoData('لا توجد فعاليات'),
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
              'حدد فعالياتك المفضلة من هنا',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Container(
                height: 50,
                padding:
                    EdgeInsets.only(bottom: 5, right: 20, left: 20, top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.2),
                      blurRadius: 8.0, // has the effect of softening the shadow
                      spreadRadius:
                          5.0, // has the effect of extending the shadow
                      offset: Offset(
                        0.0, // horizontal, move right 10
                        0.0, // vertical, move down 10
                      ),
                    ),
                  ],
                  color: Color(0xffff5c46),
                ),
                child: Text(
                  'اختار فعالياتك المفضلة',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          Interests(true, this, 3, updateInterestsNow: true,))),
            ),
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
          child:( ads?[0].images?.length??0) > 0
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
    if (_events.length >= 2) {
      if (index < 2) {
        return _buildEventItem(index); //before 2 so events item
      } else if (index == 2) {
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (!_isNoMoreData && index == _events.length + 1) {
        //we still have pages so build loader
        return _buildProgressIndicator();
      } else {
        return _buildEventItem(index - 1); //build events items after ads
      }
    } else {
      //less than 2 items
      if (index == _events.length) {
        //ads
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (index == _events.length + 1) {
        //loader
        return _buildProgressIndicator();
      } else {
        return _buildEventItem(index);
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
        for (AdvertisementData adv in ads??[]) {
          if (adv.name == "list_events") {
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

  void _changeEventsSelection(bool isMyEvents) {
    setState(() {
      _isMyEvents = isMyEvents;
      _resetEventsData();
    });
  }

  void _showDataPicker() {
    showMonthPicker(
            context: context,
//            firstDate: DateTime(DateTime.now().year - 1, 5),
//            lastDate: DateTime(DateTime.now().year, DateTime.now().month),
            initialDate: _isMyEvents ? _interestsSelectedDate : _selectedDate)
        .then((date) => setState(() {
              if (date != null) {
                if (_isMyEvents) {
                  _interestsSelectedDate = date;
                } else {
                  _selectedDate = date;
                }
                _resetEventsData();
              }
            }));
  }

  void _resetEventsData() {
    print('_resetNewsData');
    _page = 1;
    _events.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    if (_isMyEvents) {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_interestsSelectedDate);
      _eventsNetwork.getInterestsEvents(filterDate, _page, true, this);
    } else {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _eventsNetwork.getEvents(filterDate, _page, true, this);
    }
    if (_isMyEvents) {
      if (!_isNoInterest) {}
    } else {}
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);

        if (_isMyEvents) {
          String filterDate =
              new intl.DateFormat("yyyy-MM-dd").format(_interestsSelectedDate);
          _eventsNetwork.getInterestsEvents(filterDate, _page, false, this);
        } else {
          String filterDate =
              new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
          _eventsNetwork.getEvents(filterDate, _page, false, this);
        }
      }
    }
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: 'events_list');
  }

  @override
  void reloadAction() {
    if (_isMyEvents) {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_interestsSelectedDate);
      _eventsNetwork.getInterestsEvents(filterDate, _page, true, this);
    } else {
      String filterDate =
          new intl.DateFormat("yyyy-MM-dd").format(_selectedDate);
      _eventsNetwork.getEvents(filterDate, _page, true, this);
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
  void setEvents(EventsData? eventsData) {
    _page += 1;
    if (eventsData?.events != null) {
      if (eventsData?.events?.isEmpty??true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._events.addAll(eventsData?.events??[]);
        _isPerformingRequest = false;
        _isNoNetwork = false;
      });
    }
//    this._news.clear();

    setState(() {
      if (this._events.isEmpty) {
        if (_isMyEvents) {
          if (eventsData?.has_interest??false) {
            _isNoData = true;
            _isNoInterest = false;
          } else {
            _isNoInterest = true;
            _isNoData = false;
          }
        } else {
          _isNoInterest = false;
          _isNoData = true;
        }
      } else {
        _isNoInterest = false;
        _isNoData = false;
      }
    });
  }

  @override
  void addInterests() {
    //once success to add interest so we need to refresh events
    //reset data
    _page = 1;
    _events.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    String filterDate =
        new intl.DateFormat("yyyy-MM-dd").format(_interestsSelectedDate);
    _eventsNetwork.getInterestsEvents(filterDate, _page, true, this);
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

class EventsListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double? expandedHeight;
  BuildContext? context;
  EventsListState? eventsList;
  bool? isShowMyEventsOnly = false;
  NewsDeleagte? newsDeleagte;

  EventsListSliverAppBar({@required this.expandedHeight, this.eventsList,this.isShowMyEventsOnly,this.newsDeleagte});

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
              onPressed: () => Navigator.of(context).pop(null),
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
//                      builder: (BuildContext context) => Search('EVENTS'))),
                    onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            Search('EVENTS',"", null))),
                  ),
                ),
                alignment: Alignment.topLeft,
              ),
            LocalSettings.token != null?  _buildNotificationIcon(
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
                     ( eventsList?._isMyEvents??true)
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'فعالياتي',
                          style: TextStyle(
                              color: (eventsList?._isMyEvents??true)
                                  ? Colors.white
                                  : Color(0xffb1e6b1),
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          eventsList?._changeEventsSelection(true);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && (eventsList?._isMyEvents??true),
                      )
                    ],
                  ),
                  visible: !(isShowMyEventsOnly??false)?false:shrinkOffset > 90
                      ? (eventsList?._isMyEvents??true) ? true : false
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
                      !(eventsList?._isMyEvents??true)
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'كل الفعاليات',
                          style: TextStyle(
                              color: (eventsList?._isMyEvents??true)
                                  ? Color(0xffb1e6b1)
                                  : Colors.white,
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          eventsList?._changeEventsSelection(false);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && !(eventsList?._isMyEvents??true),
                      )
                    ],
                  ),
                  visible:(isShowMyEventsOnly??false)?false: shrinkOffset > 90
                      ? !(eventsList?._isMyEvents??true) ? true : false
                      : true,
                ),
              ],
            ),
          ),
        ),
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 100,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight??0)),
              child: Align(
                child: GestureDetector(
                  child: Center(
                    child: eventsList?._buildSelectedDate(),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          visible: shrinkOffset < 20 ? true : false,
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight??0;

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
              newsDeleagte?.onNotificationClicked();

            },
          ),
          alignment: Alignment.topLeft,
        ));
  }
}
