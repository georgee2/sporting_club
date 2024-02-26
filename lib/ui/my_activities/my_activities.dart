import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/activity_data.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/event.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'package:sporting_club/data/model/trips/trips_data_activity.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/ActivitiesResponseListener.dart';
import 'package:sporting_club/network/listeners/OffersServicesResponseListener.dart';
import 'package:sporting_club/network/repositories/offers_services_network.dart';
import 'package:sporting_club/ui/events/event_details.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/offers_services/offer_service_details.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/ui/trips/cancellation_policy.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class MyActivities extends StatefulWidget {
  bool _isOffers = true;

  MyActivities(this._isOffers);

  @override
  State<StatefulWidget> createState() {
    return OffersServicesListState(this._isOffers);
  }
}

class OffersServicesListState extends State<MyActivities>
    implements NoNewrokDelagate, ActivitiesResponseListener,ReloadTripsDelagate {
  bool _isloading = false;
  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;
  OffersServicesNetwork _offersServicesNetwork = OffersServicesNetwork();


  List<Offer> _items = [];
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isOffers = true;
  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;
// my data
  List<Offer> offers = [];
  List<Offer> _events = [];
  List<Trip> trips = [];
  OffersServicesListState(this._isOffers);

  @override
  void initState() {
    super.initState();
  _offersServicesNetwork.getActivities(this);

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
                    delegate: OffersServicesListSliverAppBar(
                        expandedHeight: 220, offersServicesList: this),
                    pinned: true,
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 5, bottom: 10),
                          child: Text(
                            "الرحلات",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                          visible: trips.length == 0 ? false:true,
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Container(
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.only(right: 10, left: 10, bottom: 12),
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
                            color: Colors.white,
                          ),
                          child: _getViewedTripItem(),
                        ),
                          visible: trips.length == 0 ? false:true,

                        ),
                      ],
                    ),
                  ),

//                  SliverList(
//                    delegate: SliverChildListDelegate(
//                      [
//                        Padding(
//                          padding: EdgeInsets.only(
//                              right: 10, left: 10, top: 5, bottom: 10),
//                          child: Text(
//                            "الفعاليات",
//                            textAlign: TextAlign.right,
//                            style: TextStyle(
//                                fontSize: 20,
//                                color: Color(0xff43a047),
//                                fontWeight: FontWeight.w700),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                  SliverList(
//                    delegate: SliverChildListDelegate(
//                      [
//                        Container(
//                          padding: EdgeInsets.all(10),
//                          margin:
//                              EdgeInsets.only(right: 10, left: 10, bottom: 12),
//                          decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(10),
//                            boxShadow: [
//                              BoxShadow(
//                                color: Colors.grey.withOpacity(.2),
//                                blurRadius: 8.0,
//                                // has the effect of softening the shadow
//                                spreadRadius: 5.0,
//                                // has the effect of extending the shadow
//                                offset: Offset(
//                                  0.0, // horizontal, move right 10
//                                  0.0, // vertical, move down 10
//                                ),
//                              ),
//                            ],
//                            color: Colors.white,
//                          ),
//                          child: _getViewedActivityItem(),
//                        ),
//                      ],
//                    ),
//                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (_isNoNetwork) {
                          return _buildImageNetworkError();
                        } else if (_isNoData) {
                          return _buildNoData();
                        }
                      },
                      childCount: 1,
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 5, bottom: 10),
                          child: Text(
                            "الخدمات",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                          visible: _events.length == 0?false:true,
                        ),
                      ],
                    ),
                  ),
            SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Container(
                          padding: EdgeInsets.all(10),
                          margin:
                          EdgeInsets.only(right: 10, left: 10, bottom: 12),
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
                            color: Colors.white,
                          ),
                          child: _getViewedActivityItem(),
                        ),
                          visible: _events.length == 0?false:true,
                        ),
                      ],
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 5, bottom: 10),
                          child: Text(
                            "العروض",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                          visible: offers.length == 0?false:true,
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Visibility(child:
                        Container(
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.only(right: 10, left: 10, bottom: 12),
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
                            color: Colors.white,
                          ),
                          child: _getViewedOfferItem(),
                        ),
                          visible: offers.length == 0?false:true,

                        ),
                      ],
                    ),
                  ),
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

  Widget _buildTripItem(int index) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: trips[index].image != null
                    ? trips[index].image != ""
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_2.png',
                            image: trips[index].image?.medium??"",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/placeholder_2.png',
                            height: 70,
                            width: 70,
                            fit: BoxFit.fill,
                          )
                    : Image.asset(
                        'assets/placeholder_2.png',
                        height: 70,
                        width: 70,
                        fit: BoxFit.fill,
                      ),
              ),
              Container(
                width: width - 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                      child: Align(
                        child: Text(
                          trips[index].name??"",
                          maxLines: 2,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 12, bottom: 5),
                          child: Text(
                            trips[index].start_date??"",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          index == trips.length - 1 ? SizedBox() : Divider()
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          settings: RouteSettings(name: 'TripDetails'),
          builder: (context) =>
              TripDetails(trips[index].id??0, this, false),
        ),
      )
    );
  }
//

  Widget _buildIOffertem(int index) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: offers[index].image != null
                    ? offers[index].image != ""
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_2.png',
                            image: offers[index].image??"",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/placeholder_2.png',
                            height: 70,
                            width: 70,
                            fit: BoxFit.fill,
                          )
                    : Image.asset(
                        'assets/placeholder_2.png',
                        height: 70,
                        width: 70,
                        fit: BoxFit.fill,
                      ),
              ),
              Container(
                width: width - 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                      child: Align(
                        child: Text(
                          offers[index].title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xff43a047),
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 12, bottom: 5),
                          child: Text(
                            offers[index].date ?? "",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),
//                        Container(
//                          decoration: BoxDecoration(
//                              color: Color(0xffb2b2b2),
//                              borderRadius:
//                                  new BorderRadius.all(Radius.circular(5))),
//                          padding:
//                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
//                          margin: EdgeInsets.only(bottom: 8),
//                          child: Text(
//                            "الغاء الحضور",
//                            style: TextStyle(
//                                color: Color(0xffffffff), fontSize: 12),
//                          ),
//                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          index == offers.length - 1 ? SizedBox() : Divider()
        ],
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  OfferServiceDetails(offers[index].id??0, true))),
    );
  }
  Widget _buildServicetem(int index) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: _events[index].image != null
                    ? _events[index].image != ""
                    ? FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder_2.png',
                  image: _events[index].image??"",
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/placeholder_2.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.fill,
                )
                    : Image.asset(
                  'assets/placeholder_2.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: width - 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                      child: Align(
                        child: Text(
                          _events[index].title ??"",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xff43a047),
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 12, bottom: 5),
                          child: Text(
                            _events[index].date ??"",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),
//                        Container(
//                          decoration: BoxDecoration(
//                              color: Color(0xffb2b2b2),
//                              borderRadius:
//                                  new BorderRadius.all(Radius.circular(5))),
//                          padding:
//                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
//                          margin: EdgeInsets.only(bottom: 8),
//                          child: Text(
//                            "الغاء الحضور",
//                            style: TextStyle(
//                                color: Color(0xffffffff), fontSize: 12),
//                          ),
//                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          index == _events.length - 1 ? SizedBox() : Divider()
        ],
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  OfferServiceDetails(_events[index].id??0, false))),
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
      child: NoData("لا توجد نشاطات"),
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
        padding: EdgeInsets.only(top: topPadding), child: NoNetwork(this));
  }


  Widget _getViewedTripItem() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      itemBuilder: (context, i) {
        return _buildTripItem(i);
      },
    );
  }

  Widget _getViewedActivityItem() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _events.length,
      itemBuilder: (context, i) {
        return _buildServicetem(i);
      },
    );
  }

  Widget _getViewedOfferItem() {
//    return _buildProgressIndicator();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: offers.length,
      itemBuilder: (context, i) {
        return _buildIOffertem(i);
      },
    );
//    if (_items.length >= 2) {
//      if (index < 2) {
//        return _buildIOffertem(index); //before 2 so events item
//      } else if (index == 2) {
//        return ads != null ? _buildAdsView() : SizedBox();
//      } else {
//        return _buildIOffertem(index - 1); //build events items after ads
//      }
//    } else {
//      //less than 2 items
//      if (index == _items.length) {
//        //ads
//        return ads != null ? _buildAdsView() : SizedBox();
//      } else if (index == _items.length + 1) {
//        //loader
//      } else {
//        return _buildIOffertem(index);
//      }
//    }
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

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    if (_isOffers) {
      analytics.logEvent(name: 'offers_list');
    } else {
      analytics.logEvent(name: 'services_list');
    }
  }

  @override
  void reloadAction() {
      _offersServicesNetwork.getActivities(this);

  }

  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
     // _isPerformingRequest = false;
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
  void setData(ActivityData? activityData,List<Trip>? trips) {

    setState(() {
      print("ttt");
      if(activityData?.promotions != null){
        this.offers.addAll(activityData?.promotions??[]);

      }

      if(activityData?.services != null){
        this._events.addAll(activityData?.services??[]);

      }
      if(trips != null){
        this.trips.addAll(trips);

      }
      _isPerformingRequest = false;
      _isNoNetwork = false;
      if ((activityData?.promotions?.isEmpty??false) && (activityData?.services?.isEmpty??false) ){

        _isNoData = true;
      } else {
        _isNoData = false;
      }
    });
    //activityData.promotions.trips

  }

  @override
  void setOffersCategories(CategoriesData categoriesData) {
    // TODO: implement setOffersCategories
  }

  @override
  void reloadTripsAfterBooking(User? user) {
    setState(() {
      this.offers.clear();
      this.trips.clear();
      this._events.clear();
      _offersServicesNetwork.getActivities(this);

    });

    // TODO: implement reloadTripsAfterBooking
  }
}

class OffersServicesListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  OffersServicesListState offersServicesList;

  OffersServicesListSliverAppBar(
      { this.expandedHeight=0, required this.offersServicesList});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
    print('shrinkOffset: ' + shrinkOffset.toString());
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
          "assets/offer_bg.png",
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
//        Row(
//            mainAxisSize: MainAxisSize.min,
//            mainAxisAlignment: MainAxisAlignment.end,
//            children: <Widget>[
//              LocalSettings.token != null?  _buildNotificationIcon(
//                LocalSettings.notificationsCount != null
//                    ? (LocalSettings.notificationsCount??0) > 0
//                    ? 'assets/ic_not_ac.png'
//                    : 'assets/ic_not_nr.png'
//                    : 'assets/ic_not_nr.png',
//
//              ):SizedBox(),
//            ]
//        ),
//        Align(
//          child: Padding(
//            padding: EdgeInsets.only(left: 0, right: 0, top: 5),
//            child: IconButton(
//              icon: new Image.asset('assets/ic_search_white.png'),
////              onPressed: () => Navigator.push(
////                  context,
////                  MaterialPageRoute(
////                      builder: (BuildContext context) => Search(
////                          offersServicesList._isOffers
////                              ? 'OFFERS'
////                              : 'SERVICES'))),
//              onPressed: () => Navigator.of(context).push(PageRouteBuilder(
//                  opaque: false,
//                  pageBuilder: (BuildContext context, _, __) => Search(
//                        offersServicesList._isOffers ? 'OFFERS' : 'SERVICES',
//                        null,
//                      ))),
//            ),
//          ),
//          alignment: Alignment.topLeft,
//        ),
        Center(
//          height: 100,
          child: Padding(
            padding: EdgeInsets.only(
                right: shrinkOffset > 100 ? 40 : 20,
                bottom: shrinkOffset > 100 ? 0 : 30,
                left: shrinkOffset > 100 ? 100 : 15),
            child: Align(
              child: Text(
                "نشاطاتي",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: shrinkOffset > 100 ? 20 : 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
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

              Navigator.push(
                  context!,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>     NotificationsList(),
                  ));
            },
          ),
          alignment: Alignment.topLeft,
        ));
  }


}
