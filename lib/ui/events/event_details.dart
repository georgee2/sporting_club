import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share/share.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/event.dart';
import 'package:sporting_club/data/model/news.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/EventDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/events_network.dart';
import 'package:sporting_club/network/repositories/news_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';
import 'package:sporting_club/ui/review/add_review.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/FullPhoto.dart';
import 'package:sporting_club/widgets/html_content.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:sporting_club/widgets/post_gallery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'events_list.dart';

class EventDetails extends StatefulWidget {
  String _eventID = "";
  bool isFromShare = false;

  EventDetails(this._eventID, {this.isFromShare = false});

  @override
  State<StatefulWidget> createState() {
    return EventDetailsState(this._eventID);
  }
}

class EventDetailsState extends State<EventDetails>
    implements
        EventDetailsResponseListener,
        NoNewrokDelagate,
        AddReviewDelegate {
  String _eventID = "";
  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  EventsNetwork _eventsNetwork = EventsNetwork();
  Event _event = Event();

  bool _going = false;
  bool _intersted = false;
  bool _notInteresed = false;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer, _timer2;

  EventDetailsState(this._eventID);

  @override
  void initState() {
    print(_eventID);
    _eventsNetwork.getEventDetails(_eventID, this);
    super.initState();
    _getAds();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (_timer2 != null) {
      _timer2?.cancel();
      _timer2 = null;
    }
    LocalSettings.link = "";
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async {
        if (widget.isFromShare) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
                  (Route<dynamic> route) => false);
        }else{
          Navigator.pop(context);
        }
        return true;
      },
      child: ModalProgressHUD(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: Color(0xff43a047),
            child: SafeArea(
              child: Material(
                child: CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      delegate: EventDetailsSliverAppBar(
                          expandedHeight: 230,
                          event: this._event,
                          addReviewDelegate: this,
                          eventID: _eventID,
                          isFromShare: widget.isFromShare),
                      pinned: true,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return _isNoNetwork
                            ? _buildImageNetworkError()
                            : _buildContent();
                      }, childCount: 1),
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

  Widget _buildContent() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: _isSuccess
          ? Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 20, top: 25, left: 20),
                      child: Align(
                        child: _buildEventImage(),
                        alignment: Alignment.center,
                      ),
                    ),
                    _buildEventReact(),
                  ],
                ),
                ads != null ? _buildAdsView() : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 15, left: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HtmlContent(_event.description??""),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, left: 10),
                  child: Align(
                    child: (_event.post_gallery != null &&
                           ( _event.post_gallery?.isNotEmpty??false))
                        ? PostGallery(_event.post_gallery??[])
                        : Container(),
                    alignment: Alignment.centerRight,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _buildEventImage() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            child: _event.image != null
                ? _event.image != ""
                    ?
                    // FadeInImage.assetNetwork(
                    //                     placeholder: 'assets/placeholder.png',
                    //                     image: _event.image,
                    //                     height: 200,
                    //                     width: width - 30,
                    //                     fit: BoxFit.cover,
                    //                   )
                    InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => FullImage( _event.image)));
                          Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                FullImage(_event.image??""),
                          ));
                        },
                        child: Container(
                          height: 200,
                          width: width - 30,
                          child: CachedNetworkImage(
                            imageUrl: _event.image??"",
                            placeholder: (context, url) =>
                                Image.asset("assets/placeholder_2.png"),
                            height: 200,
                            width: width - 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Image.asset(
                        'assets/placeholder.png',
                        height: 200,
                        width: width - 30,
                        fit: BoxFit.cover,
                      )
                : Image.asset(
                    'assets/placeholder.png',
                    height: 200,
                    width: width - 30,
                    fit: BoxFit.cover,
                  ),
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Image.asset(
                'assets/calendar_label.png',
                height: 75,
                width: 47,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  _event.date ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  _event.date_month ??"",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 53),
                child: Text(
                  _event.date_day ?? "",
                  style: TextStyle(
                      color: Color(0xff43a047),
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventReact() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 0, top: 200),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: 55,
          width: 250,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                child: _buildReactItem(
                    _intersted
                        ? "assets/interested_ac.png"
                        : "assets/interested_nr.png",
                    'مهتم',
                    _intersted ? Color(0xffff5c46) : Colors.black),
                onTap: () {
                  setState(() {
                    bool value = _intersted;
                    _clearEventActions();
                    _intersted = !value;
                    _eventsNetwork.reactEvent(
                        _eventID, _going, _intersted, _notInteresed, this);
                  });
                },
              ),
              SizedBox(
                width: 25,
              ),
              GestureDetector(
                child: _buildReactItem(
                    _notInteresed
                        ? "assets/notinterested_ac.png"
                        : "assets/notinterested_nr.png",
                    'غير مهتم',
                    _notInteresed ? Color(0xffa70000) : Colors.black),
                onTap: () {
                  setState(() {
                    bool value = _notInteresed;
                    _clearEventActions();
                    _notInteresed = !value;
                    _eventsNetwork.reactEvent(
                        _eventID, _going, _intersted, _notInteresed, this);
                  });
                },
              ),
              SizedBox(
                width: 25,
              ),
              GestureDetector(
                child: _buildReactItem(
                    _going ? "assets/going_ac.png" : "assets/going_nr.png",
                    'أنوي الحضور',
                    _going ? Color(0xff43a047) : Colors.black),
                onTap: () {
                  setState(() {
                    bool value = _going;
                    _clearEventActions();
                    _going = !value;
                    _eventsNetwork.reactEvent(
                        _eventID, _going, _intersted, _notInteresed, this);
                  });
                },
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
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
        ),
      ),
    );
  }

  Widget _buildReactItem(String imageName, String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          imageName,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color),
        )
      ],
    );
  }

  Widget _buildImageNetworkError() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: NoNetwork(this),
    );
  }

  Widget _buildAdsView() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 20, left: 15, top: 20, bottom: 5),
      child: GestureDetector(
        child: Container(
          child:( ads?[0].images?.length??0) > 0
              ? Image.network(
                  ads?[0].images?[viewedAdvIndex].large??"",
                  fit: BoxFit.cover,
                )
              : SizedBox(),
          //  height: 75,
          //   width: width - 30,
        ),
        onTap: () => _adsAction(),
      ),
    );
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
          if (adv.name == "inner_events") {
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

  void _clearEventActions() {
    _going = false;
    _intersted = false;
    _notInteresed = false;
  }

  void _addReview() async {
    print('_submitReview');

//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (BuildContext context) => AddReview(
//                _eventID,
//                _news.check_commnet,
//                _news.comment_id != null ? _news.comment_id : "",
//                this)));
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'event_details',
      parameters: <String, String>{
        'event_title': _event.title??"",
      },
    );
  }

  @override
  void reloadAction() {
    _eventsNetwork.getEventDetails(_eventID, this);
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

  void _shareAction() {
    //  if (event.url != null) {
    // Share.share(event.url);
    //generatedlink = LocalSettings.link;
    Share.share(LocalSettings.link??"", subject: "Sporting Club").whenComplete(() {
      print("finishhhhhhhh");
    });

    _timer2 = Timer.periodic(new Duration(seconds: 5), (timer) {
      hideLoading();
      _timer2?.cancel();
    });

    // }
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
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void addReviewSuccessfully(int reviewID) {
    setState(() {
      _event.comment_before = reviewID.toString();
    });
  }

  @override
  void setEvent(Event? event) {
    setState(() {
      _isSuccess = true;
      this._event = event?? Event();;
      _isNoNetwork = false;
      if (ApiUrls.RELEASE_MODE) {
        _sendAnalyticsEvent();
      }
      setupBranchIO();
      if (_event.interest_status != null) {
        switch (_event.interest_status) {
          case "interest":
            _intersted = true;
            break;
          case "not_interested":
            _notInteresed = true;
            break;
          case "going":
            _going = true;
            break;
          default:
            break;
        }
      }
    });
  }

  setupBranchIO() async {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: "content/12345",
      title: this._event.title??"",
      imageUrl:_event.image??"",
      keywords: ['Sporting', 'club'],
      publiclyIndex: true,
      locallyIndex: true,
    );
    BranchLinkProperties lp = BranchLinkProperties(
      channel: 'facebook',
      feature: 'sharing',
      stage: 'new user',
      campaign: "content 123 launch",
    );
    lp.addControlParam('link', "event");
    lp.addControlParam('id',  _event.id==null?_eventID.toString(): _event.id.toString());
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
      LocalSettings.link=response.result;
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  void share() {
    showLoading();
    _shareAction();
    // TODO: implement share
  }
}

class EventDetailsSliverAppBar extends SliverPersistentHeaderDelegate {
  final double? expandedHeight;
  Event? event = Event();
  AddReviewDelegate addReviewDelegate;
  BuildContext? context;
  String? eventID = "";
  String generatedlink = "";
  bool isFromShare;

  EventDetailsSliverAppBar(
      {required this.expandedHeight,
      this.event,
     required this.addReviewDelegate,
      this.eventID,
      this.isFromShare = false});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
    print('shrinkOffset: ' + shrinkOffset.toString());
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Container(
          color: shrinkOffset < 170 ? Colors.transparent : Color(0xff43a047),
          height: 80,
        ),
        Image.asset(
          "assets/intersection_3.png",
          fit: shrinkOffset < 170 ? BoxFit.fill : BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/share_ic.png'),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'مشاركة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            onTap: () {
              addReviewDelegate.share();
            },
          ),
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 0, top: 5),
            child: IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () {
                  LocalSettings.link = "";
                  if (isFromShare) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => Home()),
                            (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pop(null);
                  }
                }),
          ),
          alignment: Alignment.topRight,
        ),
        Center(
//          height: 100,
          child: Padding(
            padding: EdgeInsets.only(
                right: shrinkOffset > 110 ? 40 : 20,
                left: shrinkOffset > 110 ? 100 : 15),
            child: Align(
              child: Text(
                event?.title ?? "",
                maxLines: shrinkOffset > 110 ? 1 : 3,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: shrinkOffset > 110 ? 18 : 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 155),
          child: Column(
            children: <Widget>[
              Visibility(
                child: Opacity(
                  opacity: (1 - shrinkOffset / (expandedHeight??0)),
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 10, left: 74),
                    child: Align(
                      child: event?.category != null
                          ? _buildCategoryItem()
                          : Container(),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
                visible: shrinkOffset < 20 ? true : false,
              ),
            ],
          ),
        ),
        Visibility(
          child: Positioned(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 130,
            left: 10,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight??0)),
              child: Align(
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 20, left: 10),
                    child: event?.comment_before != null
                        ?( event?.comment_before?.isNotEmpty??false)
                            ? Image.asset('assets/review_ic.png')
                            : Image.asset('assets/review_nr.png')
                        : Container(),
                  ),
                  onTap: () => _addReview(),
                ),
                alignment: Alignment.topLeft,
              ),
            ),
          ),
          visible: shrinkOffset < 20 ? true : false,
        ),
      ],
    );
  }

  Widget _buildCategoryItem() {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
//          child: Center(
          child: Text(
            event?.category ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
//            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: Color(0xff76d275),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  void _addReview() async {
    print('_submitReview');
    bool check_commnet = false;
    bool validReview = true;
    if (event?.comment_before != null) {
      if (event?.comment_before?.isNotEmpty??false) {
        check_commnet = true;
      }
    }
    DateTime event_date = DateTime.parse(event?.date_total??"2000-01-01");
    final date2day = DateTime.now();

    final event_date_date_only =
        DateTime(event_date.year, event_date.month, event_date.day);
    final today = DateTime(date2day.year, date2day.month, date2day.day);

    print("herer date $event_date_date_only");
    print("herer date $today");

    if (event_date.isAfter(date2day) || event_date_date_only == (today)) {
      print("herer date");
      validReview = false;
      eventID = "-1";
    }
    if(event_date.isBefore(date2day) &&event_date_date_only != (today)){
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => AddReview(
                  eventID??"",
                  check_commnet,
                  check_commnet ? event?.comment_before??"" : "",
                  true,
                  addReviewDelegate,
                  validReview)));
    }else{
      Fluttertoast.showToast(msg:"يجب التقييم بعد انتهاء ميعاد الحدث", toastLength: Toast.LENGTH_LONG );
    }
  
  }

  @override
  double get maxExtent => expandedHeight??0;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
