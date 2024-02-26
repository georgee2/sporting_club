import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:share/share.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';
import 'package:sporting_club/data/model/trips/trip_price.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/OfferServiceDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/SeatsNumberResponseListener.dart';
import 'package:sporting_club/network/listeners/TripDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/network/repositories/offers_services_network.dart';
import 'package:sporting_club/network/repositories/trips_network.dart';
import 'package:sporting_club/ui/booking/rooms_number.dart';
import 'package:sporting_club/ui/booking/seats_number.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/review/add_review.dart';
import 'package:sporting_club/ui/trips/cancellation_policy.dart';
import 'package:sporting_club/ui/trips/tirps_list.dart';
import 'package:sporting_club/utilities/date_utilities.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart' as intl;

class TripDetails extends StatefulWidget {
  int _id = 0;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;
  bool isFromShare = false;

  TripDetails(this._id, this._reloadTripsDelagate, this._isFromPushNotification,
      {this.isFromShare = false});

  @override
  State<StatefulWidget> createState() {
    return TripDetailsState(
      this._id,
      this._reloadTripsDelagate,
      this._isFromPushNotification,
    );
  }
}

class TripDetailsState extends State<TripDetails>
    implements
        SeatsNumberResponseListener,
        TripDetailsResponseListener,
        NoNewrokDelagate,
        AddReviewDelegate {
  int _id = 0;
  ReloadTripsDelagate? _reloadTripsDelagate;
  bool _isFromPushNotification = false;

  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  TripsNetwork _tripsNetwork = TripsNetwork();
  Trip _trip = Trip();
  TripDetailsData _tripData = TripDetailsData();
  String _pricesStr = "";
  BookingNetwork _bookingNetwork = BookingNetwork();

  bool _isTermsAccepted = true;
  bool _isWaitingList = false;

  StreamSubscription? subscription;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer, _timer2;

  TripDetailsState(
    this._id,
    this._reloadTripsDelagate,
    this._isFromPushNotification,
  );

  @override
  void initState() {
    print(_id);
    _tripsNetwork.getTripDetails(_id, this);
    super.initState();
    _getAds();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if (result == ConnectivityResult.none && _isloading) {
        print("no network listner");
        this.hideLoading();
        this.showNetworkError();
      }
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        if (_isFromPushNotification) {
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: RouteSettings(name: 'TripsList'),
              builder: (context) => TripsList(_isFromPushNotification, true),
            ),
          );
        } else if (widget.isFromShare) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pop(null);
        }
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
                  slivers: [
                    SliverPersistentHeader(
                      delegate: TripDetailsSliverAppBar(
                          expandedHeight: 230,
                          tripData: this._tripData,
                          addReviewDelegate: this,
                          isFromPushNotification: _isFromPushNotification,
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
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 20),
                  child: Align(
                    child: _buildTripImage(),
                    alignment: Alignment.center,
                  ),
                ),
                ads != null ? _buildAdsView() : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                  child: Align(
                    child: Text(
                      "تاريخ الرحلة",
                      style: TextStyle(
                          color: Color(0xff43a047),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                _buildTripDates(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 20),
                  child: Container(
                    height: 0.8,
                    color: Color(0xffE0E0E0),
                  ),
                ),
                _buildTripSeats(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 20),
                  child: Container(
                    height: 0.8,
                    color: Color(0xffE0E0E0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                  child: Align(
                    child: Text(
                      "تفاصيل الاقامة",
                      style: TextStyle(
                          color: Color(0xff43a047),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 5, left: 10),
                  child: Align(
                    child: Text(
                      _trip.accommodation_details != null
                          ? Validation.replaceArabicNumber(
                              _trip.accommodation_details ?? "0")
                          : "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                _trip.optional_program_details != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                        child: Align(
                          child: Text(
                            "برنامح المزارات الاختيارية",
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      )
                    : SizedBox(),
                _trip.optional_program_details != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 20, top: 5, left: 10),
                        child: Align(
                          child: Text(
                            _trip.optional_program_details != null
                                ? Validation.replaceArabicNumber(
                                    _trip.optional_program_details??"0")
                                : "",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                  child: Align(
                    child: Text(
                      "قيمة الاشتراك",
                      style: TextStyle(
                          color: Color(0xff43a047),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 5, left: 10),
                  child: Align(
                    child: Text(
                      _pricesStr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                _trip.category?.id != null
                    ? _trip.category?.id == 2
                        ? Padding(
                            padding:
                                EdgeInsets.only(right: 20, top: 20, left: 10),
                            child: Align(
                              child: Text(
                                "قيمة التأشيرة",
                                style: TextStyle(
                                    color: Color(0xff43a047),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          )
                        : SizedBox()
                    : SizedBox(),
                _trip.category != null
                    ? _trip.category?.id == 2
                        ? Padding(
                            padding:
                                EdgeInsets.only(right: 20, top: 5, left: 10),
                            child: Align(
                              child: Text(
                                _trip.visa_price != null
                                    ? Validation.replaceArabicNumber(
                                            _trip.visa_price.toString()) +
                                        " جنيه مصري "
                                    : "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          )
                        : SizedBox()
                    : SizedBox(),
                _trip.category != null
                    ? _trip.category?.id == 2 && _trip.visa_requirements != null
                        ? Padding(
                            padding:
                                EdgeInsets.only(right: 20, top: 10, left: 10),
                            child: Align(
                              child: Text(
                                "المستندات المطلوبة للتأشيرة",
                                style: TextStyle(
                                    color: Color(0xff43a047),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          )
                        : SizedBox()
                    : SizedBox(),
                _trip.category != null
                    ? _trip.category?.id == 2
                        ? Padding(
                            padding:
                                EdgeInsets.only(right: 20, top: 5, left: 10),
                            child: Align(
                              child: Text(
                                _trip.visa_requirements != null
                                    ? Validation.replaceArabicNumber(
                                        _trip.visa_requirements??"0")
                                    : "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          )
                        : SizedBox()
                    : SizedBox(),
                _buildBookingEndDate(),
                _trip.limit_age != null || _trip.max_age != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 20, top: 20, left: 20),
                        child: Container(
                          height: 0.8,
                          color: Color(0xffE0E0E0),
                        ),
                      )
                    : SizedBox(),
                _trip.limit_age != null && _trip.max_age != null
                    ? Align(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 20, left: 10, top: 20, bottom: 5),
                          child: Text(
                            " تنبيه: العمر المناسب للرحلة بين ${_trip.limit_age} و  ${_trip.max_age}  سنة ",
                            style: TextStyle(
                                color: Color(0xff03240a),
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        alignment: Alignment.center,
                      )
                    : _trip.limit_age != null
                        ? Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 20, left: 10, top: 20, bottom: 5),
                              child: Text(
                                " تنبيه: يجب ألا يقل عمر المشترك عن ${_trip.limit_age} سنوات",
                                style: TextStyle(
                                    color: Color(0xff03240a),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            alignment: Alignment.center,
                          )
                        : _trip.max_age != null
                            ? Align(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 20, left: 10, top: 20, bottom: 5),
                                  child: Text(
                                    " تنبيه: يجب ألا يزيد عمر المشارك عن ${_trip.max_age} سنوات",
                                    style: TextStyle(
                                        color: Color(0xff03240a),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                alignment: Alignment.center,
                              )
                            : SizedBox(),

                // _buildTerms(),
                _buildPayButton(),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _buildTripImage() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        child: _trip.image != null
            ? _trip.image?.original != null
                ? FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: _trip.image?.original??"",
                    height: 200,
                    width: width - 30,
                    fit: BoxFit.cover,
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
    );
  }

  Widget _buildTripDates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 10, bottom: 5),
                child: Text(
                  "من",
                  style: TextStyle(
                    color: Color(0xff00701a),
                    fontSize: 16,
                  ),
                ),
              ),
              alignment: Alignment.centerRight,
            ),
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 0, bottom: 0),
                child: Text(
                  _trip.start_date ?? "",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              alignment: Alignment.centerRight,
            )
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 10, bottom: 5),
                child: Text(
                  "إلى",
                  style: TextStyle(
                    color: Color(0xff00701a),
                    fontSize: 16,
                  ),
                ),
              ),
              alignment: Alignment.centerRight,
            ),
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 0, bottom: 0),
                child: Text(
                  _trip.end_date?? "",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              alignment: Alignment.centerRight,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTripSeats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 5),
                child: Text(
                  "عدد الأماكن المتاحة",
                  style: TextStyle(
                      color: Color(0xff76d275),
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              alignment: Alignment.centerRight,
            ),
            Align(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 20, left: 10, top: 0, bottom: 0),
                child: Text(
                  _trip.available_seats != null
                      ? Validation.replaceArabicNumber(
                          _trip.available_seats.toString())
                      : "",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              alignment: Alignment.centerRight,
            )
          ],
        ),
        _trip.waiting_list_count != null
            ? _trip.waiting_list_count != 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 20, left: 10, top: 20, bottom: 5),
                          child: Text(
                            "قائمة الانتظار",
                            style: TextStyle(
                                color: Color(0xffff5c46),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      Align(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 20, left: 10, top: 0, bottom: 0),
                          child: Text(
                            _trip.waiting_list_count.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      )
                    ],
                  )
                : SizedBox()
            : SizedBox(),
      ],
    );
  }

  Widget _buildBookingEndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 5),
            child: Text(
              "معاد انتهاء الحجز",
              style: TextStyle(
                  color: Color(0xffb6b9c0),
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          alignment: Alignment.centerRight,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 10, left: 10, top: 20, bottom: 5),
            child: Text(
              _trip.booking_end_date ?? "",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          alignment: Alignment.centerRight,
        )
      ],
    );
  }

  Widget _buildTerms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 20, left: 0, top: 10, bottom: 5),
            child: GestureDetector(
              child: _isTermsAccepted
                  ? Icon(
                      Icons.check_box,
                      color: Color(0xffff5c46),
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      color: Color(0xffbfbfbf),
                    ),
              onTap: () {
                setState(() {
                  _isTermsAccepted = !_isTermsAccepted;
                });
              },
            ),
          ),
          alignment: Alignment.centerRight,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(right: 10, left: 0, top: 10, bottom: 5),
            child: Text(
              "أوافق على الشروط والأحكام الخاصة ب",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          alignment: Alignment.centerRight,
        ),
        GestureDetector(
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(right: 0, left: 5, top: 10, bottom: 5),
              child: Text(
                "سياسة اﻹلغاء",
                style: TextStyle(color: Color(0xff43a047), fontSize: 16),
              ),
            ),
            alignment: Alignment.centerRight,
          ),
          onTap: () => _cancellationPolicyAction(),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 25),
        child: Container(
          child: Center(
            child: Text(
              _getBookingButtonValue(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 20, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
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
            color: _isTermsAccepted ? Color(0xffff5c46) : Color(0xffbfbfbf),
          ),
          height: 50,
        ),
      ),
      onTap: () => _bookingAction(),
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
      padding: EdgeInsets.only(right: 20, left: 15, top: 20, bottom: 5),
      child: GestureDetector(
        child: Container(
          child: (ads?[0].images?.length ?? 0) > 0
              ? Image.network(
                  ads?[0].images?[viewedAdvIndex].large ?? "",
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

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads =
          LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty ?? false) {
        for (AdvertisementData adv in ads ?? []) {
          if (adv.name == "inner_trips") {
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
      if (ads?.isNotEmpty ?? false) {
        if (ads?[0].image_duration != null) {
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

  void _cancellationPolicyAction() async {
    print(
        "tripData.trip.cancellation_policy ${_tripData.trip?.cancellation_policy}");
    if (_tripData.trip?.cancellation_policy != null) {
//      if (await UrlLauncher.canLaunch(_tripData.cancellation_policy_url)) {
//        await UrlLauncher.launch(_tripData.cancellation_policy_url);
//      } else {
//        print("can't launch");
//      }
//    }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CancellationPolicy(
                _tripData.id ?? 0, _tripData.trip?.cancellation_policy ?? ""),
          ));
    }
  }

  void _bookingAction() {
    if (_isTermsAccepted) {
      if (_checkTripTime(_trip)) {
        _setSeatsNumberAction();
        //  Navigator.of(context).push(PageRouteBuilder(
        //       opaque: false,
        //       pageBuilder: (BuildContext context, _, __) => SeatsNumber(
        //             this._trip,
        //             2,
        //             this._isWaitingList,
        //             _reloadTripsDelagate,
        //             this._isFromPushNotification,
        //           )));
        // } else {
        //   Fluttertoast.showToast(msg:"حجز الرحلة لم يبدأ بعد", context,
        //       duration: Toast.LENGTH_LONG);
      }
    }
  }

  void _setSeatsNumberAction() {
    FocusScope.of(context).requestFocus(new FocusNode());
    print('setSeatsNumberAction');
    // print("_controller.text: " + _controller.text);
    // if (_isWaitingList) {
    //   _bookingNetwork.setWaitnigSeatsNumber(
    //       2, _trip.id, this);
    // } else {
    _bookingNetwork.getSeatsNumber(_trip.id ?? 0, this);
    //  }
  }

  void _setInterest() {
    print('_setInterest');
//    _offersServicesNetwork.interestOfferOrServices(_isOffers, _id, this);
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'trip_details',
      parameters: <String, String>{
        'trip_title': _trip.name ?? "",
      },
    );
  }

  void setTripPrices() {
    if (_trip.trip_prices != null) {
      for (TripPrice tripPrice in _trip.trip_prices ?? []) {
        String value = "";
        if (tripPrice.type != null) {
          if (tripPrice.type == 0) {
            //child room
            value = "-";
            value += "اشتراك الطفل ";
            if (tripPrice.seat_type != null) {
              if (tripPrice.seat_type?.name != null) {
                value = value +( tripPrice.seat_type?.name??"");
              }
            }
            if (tripPrice.price != null) {
              value = value +
                  " بقيمة " +
                  Validation.replaceArabicNumber(tripPrice.price.toString()) +
                  " جنيه مصري";
            }
          } else {
            //adult room
            value = "-";
            value += "اشتراك الفرد ";
            if (tripPrice.room_type != null) {
              if (tripPrice.room_type?.name != null) {
                value = "\u{200E}" +
                    value +
                    (tripPrice.room_type?.name ?? "") +
                    " ";

//                value = value + tripPrice.room_type.name + " ";
              }
            }
            if (tripPrice.room_view != null) {
              if (tripPrice.room_view?.name != null) {
                value = "\u{200E}" + value + (tripPrice.room_view?.name ?? "");

//                value = value + tripPrice.room_view.name + " ";
              }
            }
            if (tripPrice.price != null) {
              value = "\u{200E}" +
                  value +
                  " بقيمة " +
                  Validation.replaceArabicNumber(tripPrice.price.toString()) +
                  " جنيه مصري";

//              value = value + tripPrice.price.toString() + " جنيه مصري";
            }
          }
        }
        if (value.isNotEmpty) {
          setState(() {
            if (_pricesStr.isNotEmpty) {
              _pricesStr = Validation.replaceArabicNumber(_pricesStr);
              _pricesStr = _pricesStr + "\n" + value;
            } else {
              _pricesStr = Validation.replaceArabicNumber(_pricesStr);

              _pricesStr = value;
            }
          });
        }
      }
    }
  }

  String _getBookingButtonValue() {
    String value = 'الحجز والدفع';
    if (_trip.available_seats != null) {
      if ((_trip.available_seats??0) <= 0) {
        value = "حجز في قائمة الانتظار";
        _isWaitingList = true;
      }
    }
    if (_trip.booking_end_date != null) {
      intl.DateFormat dateFormat = intl.DateFormat("dd-MM-yyyy");
      DateTime endTime =
          dateFormat.parse(_trip.booking_end_date ?? "2000-1-01");

      final currentTime = DateTime.now();

      if (currentTime.isAfter(endTime)&&(!currentTime.isAtSameDay(endTime)) )  {
        value = "حجز في قائمة الانتظار";
        _isWaitingList = true;
      }
    }
    return value;
  }

  void _shareAction() {
    if (LocalSettings.link != "null") {
//      Share.share(LocalSettings.link??"");
      Share.share(LocalSettings.link ?? "", subject: "Sporting Club");
      _timer2 = Timer.periodic(new Duration(seconds: 5), (timer) {
        hideLoading();
        _timer2?.cancel();
      });
      //  Share.share(tripData.trip_web_url);
    }
  }

  @override
  void reloadAction() {
    _tripsNetwork.getTripDetails(_id, this);
  }

  @override
  void hideLoading() {
    print("hide Loading");
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
    print("showNetworkError");
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
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void showInterestedSuccessfully() {
    setState(() {
//      _data.interest = true;
    });
  }

  @override
  void setTrip(TripDetailsData? tripData) {
    this._tripData = tripData ?? TripDetailsData();
    if (tripData?.trip != null) {
      setupBranchIO();

      setState(() {
        _isSuccess = true;
        this._trip = tripData?.trip??Trip();
        _isNoNetwork = false;
        if (ApiUrls.RELEASE_MODE) {
          _sendAnalyticsEvent();
        }
        setTripPrices();
      });
    }
  }

  setupBranchIO() async {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: "content/12345",
      title: _trip.name??"",
      imageUrl: _trip.image?.medium??"",
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
    lp.addControlParam('link', 'trip');
    lp.addControlParam(
        'id', _trip.id == null ? _id.toString() : _trip.id.toString());
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
      LocalSettings.link = response.result;
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  bool _checkTripTime(Trip trip) {
    DateTime startTime = new intl.DateFormat(
      "dd-MM-yyyy",
    ).parse(trip.booking_start_date??"2000-01-01");
    print(trip.booking_start_date);

    final currentTime = DateTime.now();
    print(currentTime);
    ;
    print(startTime);
    ;

    if (currentTime.isBefore(startTime)) {
      // do something
      print('valid date');
      return false;
    } else {
      return true;
    }
  }

  @override
  void addReviewSuccessfully(int reviewID) {
    // TODO: implement addReviewSuccessfully
  }

  @override
  void share() {
    showLoading();
    _shareAction();
    // TODO: implement share
  }

  @override
  void showSuccess(BookingRequest? bookingRequest) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                //    RegisterMembership(
                //  )));
                RoomsNumber(
                  this._trip,
                  bookingRequest?? BookingRequest(),
                  MediaQuery.of(context).size.width,
                  _reloadTripsDelagate,
                  this._isFromPushNotification,
                )));
  }

  @override
  void showSuccessCancel() {
    // TODO: implement showSuccessCancel
  }

  @override
  void showSuccessWaiting() {
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: 'سيتم التواصل معك في حال توافر أماكن متاحة بالرحلة',
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showSuccessCount(String? count) {
    print("count$count");
    int count_seat = int.parse(count??"0");
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => SeatsNumber(
              this._trip,
              count_seat,
              this._isWaitingList,
              _reloadTripsDelagate,
              this._isFromPushNotification,
            )));
    // TODO: implement showSuccessCount
  }

  @override
  void showSuccessMemberName(String? memberName, String MemberId) {
    // TODO: implement showSuccessMemberName
  }
}

class TripDetailsSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  TripDetailsData tripData = TripDetailsData();
  BuildContext? context;
  bool isFromPushNotification = false;
  AddReviewDelegate addReviewDelegate;
  bool isFromShare;

  TripDetailsSliverAppBar(
      {this.expandedHeight=0,
  required   this.tripData,
  required this.addReviewDelegate,
  required this.isFromPushNotification,
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
                  if (isFromPushNotification) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: RouteSettings(name: 'TripsList'),
                        builder: (context) =>
                            TripsList(isFromPushNotification, true),
                      ),
                    );
                  } else if (isFromShare) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Home()),
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
                tripData.trip?.name ?? "",
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
                  opacity: (1 - shrinkOffset / (expandedHeight )),
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 10, left: 74),
                    child: Align(
                      child: tripData.trip != null
                          ? tripData.trip?.category?.id != null
                              ? Container(
                                  child: _buildTripCode(),
                                  height: 35,
                                )
                              : SizedBox()
                          : SizedBox(),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
                visible: shrinkOffset < 20 ? true : false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripCode() {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: Row(
        children: <Widget>[
          Text(
            "كود الرحلة",
            style: TextStyle(
              color: Color(0xffD2EED2),
              fontSize: 15,
            ),
//            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "${tripData.trip?.id ?? ''}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
//            ),
          ),
        ],
      ),
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
            tripData.trip?.category?.id == 0 ? "رحلات داخلية" : "رحلات خارجية",
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

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
