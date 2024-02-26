import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/serviceCategories_data.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/OffersServicesResponseListener.dart';
import 'package:sporting_club/network/repositories/offers_services_network.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'offer_service_details.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class OffersList extends StatefulWidget {
  bool _isOffers = true;

  OffersList(this._isOffers);

  @override
  State<StatefulWidget> createState() {
    return OffersListState(this._isOffers);
  }
}

class OffersListState extends State<OffersList>
    implements NoNewrokDelagate, OffersServicesResponseListener,NewsDeleagte {
  bool _isloading = false;
  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;
  OffersServicesNetwork _offersServicesNetwork = OffersServicesNetwork();

  String _selectedCategoryId = "";
  List<Category> _categories = [];

  List<Offer> _items = [];
  int _page = 1;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;

  bool _isOffers = true;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;

  OffersListState(this._isOffers);

  @override
  void initState() {
    super.initState();
    _offersServicesNetwork.getCategories(_isOffers, this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
    });
    LocalSettings.link = "";
    if (ApiUrls.RELEASE_MODE) {
      _sendAnalyticsEvent();
    }
    _getAds();
    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in offers  ");
      LocalSettings.notificationsCount =  1;
      setState(() {});
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
                    delegate: OffersServicesListSliverAppBar(
                        expandedHeight: 220, offersServicesList: this,newsDeleagte: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        if (_isNoNetwork) {
                          return _buildImageNetworkError();
                        } else if (_isNoData) {
                          return _buildNoData();
                        } else {
                          return _getViewedItem(index);
                        }
                      },
                      childCount: _isNoData || _isNoNetwork
                          ? 1
                          : _items.isEmpty
                          ? 0
                          : _isNoMoreData
                          ? _items.length + 1 //data + ads
                          : _items.length + 2,
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

  Widget _buildItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 30 : 5, bottom: 10),
          child: Container(
            height: 110,
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
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: _items[index].image != null
                      ? _items[index].image != ""
                      ? FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder_2.png',
                    image: _items[index].image??"",
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/placeholder_2.png',
                    height: 110,
                    width: 110,
                    fit: BoxFit.fill,
                  )
                      : Image.asset(
                    'assets/placeholder_2.png',
                    height: 110,
                    width: 110,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  width: width - 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                        child: Align(
                          child: Text(
                            _items[index].title?? "",
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
                      Align(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 12, bottom: 5),
                          child: Text(
                            _items[index].date??"",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  OfferServiceDetails(_items[index].id??0, _isOffers))),
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
      child: NoData(_isOffers ? 'لا يوجد عروض' : 'لا توجد خدمات'),
    );
  }

  Widget _buildCategoryItem(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 0 ? 20 : 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
          child: Text(
            _categories[index].name?? "",
            style: TextStyle(
              color: _categories[index].id == _selectedCategoryId
                  ? Colors.white
                  : Color(0xffb1e6b1),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _categories[index].id == _selectedCategoryId
                  ? Color(0xff43a047)
                  : Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _categories[index].id == _selectedCategoryId
                ? Color(0xff43a047)
                : Colors.transparent,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedCategoryId = _categories[index].id??"";
            _resetData();
          });
        },
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
        padding: EdgeInsets.only(top: topPadding), child: NoNetwork(this));
  }

  Widget _buildAdsView() {
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
        ),
        onTap: () => _adsAction(),
      ),
    );
  }

  Widget _getViewedItem(int index) {
    if (_items.length >= 2) {
      if (index < 2) {
        return _buildItem(index); //before 2 so events item
      } else if (index == 2) {
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (!_isNoMoreData && index == _items.length + 1) {
        //we still have pages so build loader
        return _buildProgressIndicator();
      } else {
        return _buildItem(index - 1); //build events items after ads
      }
    } else {
      //less than 2 items
      if (index == _items.length) {
        //ads
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (index == _items.length + 1) {
        //loader
        return _buildProgressIndicator();
      } else {
        return _buildItem(index);
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
    String adsName = _isOffers ? "list_offers" : "list_services";
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == adsName) {
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

  void _resetData() {
    print('_resetData');
    _page = 1;
    _items.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    _offersServicesNetwork.getOffersOrServices(
        _isOffers, _page, _selectedCategoryId, true, this);
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);
        _offersServicesNetwork.getOffersOrServices(
            _isOffers, _page, _selectedCategoryId, false, this);
      }
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
    if (_categories.isEmpty) {
      _offersServicesNetwork.getCategories(_isOffers, this);
    } else {
      _offersServicesNetwork.getOffersOrServices(
          _isOffers, _page, _selectedCategoryId, true, this);
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
  void setCategories(ServiceCategoriesData? categoriesData) {

  }


  @override
  void setOffersCategories(CategoriesData? categoriesData) {
    if (categoriesData?.categories != null) {
      setState(() {
        this._categories.clear();
        this._categories = categoriesData?.categories??[];
        if (_categories.length > 0) {
          this._selectedCategoryId = _categories[0].id??"";
        }
        _offersServicesNetwork.getOffersOrServices(
            _isOffers, _page, _selectedCategoryId, true, this);
      });
    }
  }

  @override
  void setData(List<Offer>? items) {
    _page += 1;
    if (items?.isEmpty??true) {
      setState(() {
        _isNoMoreData = true;
      });
    }
    setState(() {
      this._items.addAll(items??[]);

      _isPerformingRequest = false;
      _isNoNetwork = false;
    });
    if (this._items.isEmpty) {
      _isNoData = true;
    } else {
      _isNoData = false;
    }
  }

  @override
  void onNotificationClicked() {
    setState(() {
      LocalSettings.notificationsCount = 0;
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>     NotificationsList(),
          ));
    });
  }

  @override
  void selectedSubCategory(Category category) {
    // TODO: implement selectedSubCategory
  }
}

class OffersServicesListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  OffersListState offersServicesList;
  NewsDeleagte newsDeleagte;

  OffersServicesListSliverAppBar(
      { this.expandedHeight=0,required this.offersServicesList,required this.newsDeleagte});

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
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Align(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 5),
                  child: IconButton(
                    icon: new Image.asset('assets/ic_search_white.png'),
                    onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            Search(
                                offersServicesList._isOffers ? 'OFFERS' : 'SERVICES',"",
                                null))),
                  ),
                ),
                alignment: Alignment.topLeft,
              ),
              LocalSettings.token != null?  _buildNotificationIcon(
                LocalSettings.notificationsCount != null
                    ?( LocalSettings.notificationsCount??0) > 0
                    ? 'assets/ic_not_ac.png'
                    : 'assets/ic_not_nr.png'
                    : 'assets/ic_not_nr.png',

              ):SizedBox(),
            ]
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                right: shrinkOffset > 100 ? 40 : 20,
                bottom: shrinkOffset > 100 ? 0 : 30,
                left: shrinkOffset > 100 ? 100 : 15),
            child: Align(
              child: Text(
                offersServicesList._isOffers ? 'العروض' : 'الخدمات',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: shrinkOffset > 100 ? 20 : 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 125),
          child: Column(
            children: <Widget>[
              Visibility(
                child: Opacity(
                  opacity: (1 - shrinkOffset / (expandedHeight)),
                  child: Padding(
                    padding: EdgeInsets.only(right: 0, top: 0, left: 0),
                    child: Align(
                      child: Container(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return offersServicesList._buildCategoryItem(index);
                          },
                          itemCount: offersServicesList._categories.length,
                          scrollDirection: Axis.horizontal,
                        ),
                        height: 35,
                      ),
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
newsDeleagte.onNotificationClicked();
            },
          ),
          alignment: Alignment.topLeft,
        ));
  }

}
